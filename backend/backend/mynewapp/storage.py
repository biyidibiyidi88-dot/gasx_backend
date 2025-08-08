import os
import uuid
from django.core.files.storage import Storage
from django.conf import settings
from django.utils.deconstruct import deconstructible
from supabase import create_client, Client
from io import BytesIO


@deconstructible
class SupabaseStorage(Storage):
    """
    Custom storage backend for Supabase Storage
    """
    
    def __init__(self):
        self.supabase_url = os.getenv('SUPABASE_URL')
        self.supabase_key = os.getenv('SUPABASE_ANON_KEY')
        self.bucket_name = os.getenv('SUPABASE_BUCKET_NAME', 'profile-images')
        
        if not self.supabase_url or not self.supabase_key:
            raise ValueError("SUPABASE_URL and SUPABASE_ANON_KEY must be set in environment variables")
        
        self.client: Client = create_client(self.supabase_url, self.supabase_key)
    
    def _save(self, name, content):
        """
        Save file to Supabase Storage
        """
        # Generate unique filename to avoid conflicts
        file_extension = name.split('.')[-1] if '.' in name else ''
        unique_name = f"{uuid.uuid4()}.{file_extension}" if file_extension else str(uuid.uuid4())
        
        # Read file content
        content.seek(0)
        file_data = content.read()
        
        try:
            # Upload to Supabase Storage
            result = self.client.storage.from_(self.bucket_name).upload(
                path=unique_name,
                file=file_data,
                file_options={"content-type": self._get_content_type(name)}
            )
            
            if result.status_code == 200:
                return unique_name
            else:
                raise Exception(f"Upload failed: {result}")
                
        except Exception as e:
            raise Exception(f"Failed to upload to Supabase: {str(e)}")
    
    def _open(self, name, mode='rb'):
        """
        Open file from Supabase Storage
        """
        try:
            result = self.client.storage.from_(self.bucket_name).download(name)
            return BytesIO(result)
        except Exception as e:
            raise Exception(f"Failed to open file from Supabase: {str(e)}")
    
    def delete(self, name):
        """
        Delete file from Supabase Storage
        """
        try:
            result = self.client.storage.from_(self.bucket_name).remove([name])
            return result.status_code == 200
        except Exception as e:
            print(f"Failed to delete file from Supabase: {str(e)}")
            return False
    
    def exists(self, name):
        """
        Check if file exists in Supabase Storage
        """
        try:
            result = self.client.storage.from_(self.bucket_name).list(path="", search=name)
            return len(result) > 0
        except Exception:
            return False
    
    def url(self, name):
        """
        Get public URL for file in Supabase Storage
        """
        try:
            # Construct the public URL directly
            public_url = f"{self.supabase_url}/storage/v1/object/public/{self.bucket_name}/{name}"
            return public_url
        except Exception as e:
            print(f"Failed to get public URL: {str(e)}")
            return None
    
    def size(self, name):
        """
        Get file size from Supabase Storage
        """
        try:
            result = self.client.storage.from_(self.bucket_name).list(path="", search=name)
            if result and len(result) > 0:
                return result[0].get('metadata', {}).get('size', 0)
            return 0
        except Exception:
            return 0
    
    def _get_content_type(self, name):
        """
        Determine content type based on file extension
        """
        extension = name.lower().split('.')[-1] if '.' in name else ''
        content_types = {
            'jpg': 'image/jpeg',
            'jpeg': 'image/jpeg',
            'png': 'image/png',
            'gif': 'image/gif',
            'webp': 'image/webp',
            'bmp': 'image/bmp',
            'svg': 'image/svg+xml',
        }
        return content_types.get(extension, 'application/octet-stream')
