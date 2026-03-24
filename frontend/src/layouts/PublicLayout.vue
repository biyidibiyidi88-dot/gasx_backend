<template>
  <div class="min-h-screen flex flex-col relative overflow-hidden">
    <!-- Three.js canvas for 3D glowing spheres and particles background -->
    <canvas ref="threeCanvas" class="fixed inset-0 z-0"></canvas>
    <!-- Main content with semi-transparent backgrounds for header/footer, transparent for body -->
    <public-header class="relative z-20"></public-header>
    <Body class="flex-1 relative z-10"></Body>
    <public-footer class="relative z-20"></public-footer>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import * as THREE from 'three'
import PublicHeader from "../components/public/PublicHeader.vue";
import PublicFooter from "../components/public/PublicFooter.vue";
import Body from "../components/public/Body.vue";

// Canvas reference for Three.js
const threeCanvas = ref(null)

// Three.js variables
let scene, camera, renderer, mesh, grid, points
const mouse = new THREE.Vector2()

// Initialize Three.js scene
const initThreeJS = () => {
  scene = new THREE.Scene()
  scene.background = new THREE.Color(0x020617) // Slate 950

  camera = new THREE.PerspectiveCamera(60, window.innerWidth / window.innerHeight, 0.1, 1000)
  camera.position.z = 80
  camera.position.y = 20

  renderer = new THREE.WebGLRenderer({ canvas: threeCanvas.value, antialias: true, alpha: true })
  renderer.setSize(window.innerWidth, window.innerHeight)
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))

  // Create a structured wave/grid
  const geometry = new THREE.PlaneGeometry(200, 200, 50, 50)
  const material = new THREE.MeshStandardMaterial({
    color: 0x0f172a,
    wireframe: true,
    transparent: true,
    opacity: 0.2
  })
  mesh = new THREE.Mesh(geometry, material)
  mesh.rotation.x = -Math.PI / 2
  scene.add(mesh)

  // Add glowing points at intersections
  const pointsGeometry = new THREE.BufferGeometry()
  const count = 51 * 51
  const positions = new Float32Array(count * 3)
  const colors = new Float32Array(count * 3)
  
  for (let i = 0; i < count; i++) {
    const x = (i % 51) - 25
    const z = Math.floor(i / 51) - 25
    positions[i * 3] = x * 4
    positions[i * 3 + 1] = 0
    positions[i * 3 + 2] = z * 4
    
    colors[i * 3] = 0.1
    colors[i * 3 + 1] = 0.5
    colors[i * 3 + 2] = 0.5
  }
  
  pointsGeometry.setAttribute('position', new THREE.BufferAttribute(positions, 3))
  pointsGeometry.setAttribute('color', new THREE.BufferAttribute(colors, 3))
  
  const pointsMaterial = new THREE.PointsMaterial({
    size: 0.4,
    vertexColors: true,
    transparent: true,
    opacity: 0.8,
    blending: THREE.AdditiveBlending
  })
  
  points = new THREE.Points(pointsGeometry, pointsMaterial)
  points.rotation.x = -Math.PI / 2
  scene.add(points)

  // Add lights
  const mainLight = new THREE.PointLight(0x2dd4bf, 2, 200) // Teal light
  mainLight.position.set(0, 50, 50)
  scene.add(mainLight)

  const secondaryLight = new THREE.PointLight(0x3b82f6, 1.5, 200) // Blue light
  secondaryLight.position.set(-50, 30, 20)
  scene.add(secondaryLight)

  const ambientLight = new THREE.AmbientLight(0x1e293b, 0.5)
  scene.add(ambientLight)

  // Mouse move effect
  const onMouseMove = (event) => {
    mouse.x = (event.clientX / window.innerWidth) * 2 - 1
    mouse.y = -(event.clientY / window.innerHeight) * 2 + 1
  }
  window.addEventListener('mousemove', onMouseMove)

  const onWindowResize = () => {
    camera.aspect = window.innerWidth / window.innerHeight
    camera.updateProjectionMatrix()
    renderer.setSize(window.innerWidth, window.innerHeight)
  }
  window.addEventListener('resize', onWindowResize)

  onUnmounted(() => {
    window.removeEventListener('mousemove', onMouseMove)
    window.removeEventListener('resize', onWindowResize)
    renderer.dispose()
  })
}

// Animation loop
const animate = () => {
  const time = Date.now() * 0.0005
  requestAnimationFrame(animate)

  // Animate the mesh surface
  const positions = mesh.geometry.attributes.position.array
  const pointPositions = points.geometry.attributes.position.array
  
  for (let i = 0; i < positions.length; i += 3) {
    const x = positions[i]
    const y = positions[i + 1]
    
    // Wave effect
    const wave1 = Math.sin(x * 0.1 + time) * 2
    const wave2 = Math.cos(y * 0.1 + time) * 2
    const dist = Math.sqrt(Math.pow(x/4 - mouse.x * 20, 2) + Math.pow(y/4 - mouse.y * 20, 2))
    const mouseEffect = Math.max(0, 10 - dist) * 0.5
    
    positions[i + 2] = wave1 + wave2 + mouseEffect
    if (i < pointPositions.length) {
      pointPositions[i + 1] = wave1 + wave2 + mouseEffect // Point Y is Mesh Z
    }
  }
  
  mesh.geometry.attributes.position.needsUpdate = true
  points.geometry.attributes.position.needsUpdate = true

  // Subtle camera movement
  camera.position.x += (mouse.x * 10 - camera.position.x) * 0.05
  camera.position.y += (-mouse.y * 10 + 20 - camera.position.y) * 0.05
  camera.lookAt(0, 0, 0)

  renderer.render(scene, camera)
}


// Start Three.js when component is mounted
onMounted(() => {
  initThreeJS()
  animate()
})
</script>

<style scoped>
/* Ensure the layout doesn't interfere with the Three.js canvas */
:deep(.min-h-screen) {
  margin: 0;
  padding: 0;
  height: 100%;
  overflow: hidden;
}

/* Ensure canvas stays in background */
canvas {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}
</style>