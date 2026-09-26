from rest_framework.permissions import BasePermission


class IsSystemAdmin(BasePermission):
    """Allow users explicitly marked as GaSX admins, including legacy admins."""

    message = "Administrator access is required."

    def has_permission(self, request, view):
        user = request.user
        return bool(
            user
            and user.is_authenticated
            and (user.is_superuser or user.is_admin or user.is_staff)
        )
