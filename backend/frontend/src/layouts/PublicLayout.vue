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
let scene, camera, renderer, spheres = [], particles = []
const sphereCount = 10 // Number of glowing spheres
const particleCount = 200 // Number of background particles

// Initialize Three.js scene
const initThreeJS = () => {
  // Create scene
  scene = new THREE.Scene()
  scene.background = new THREE.Color(0x0a0a1a) // Deep blue-black background

  // Set up camera
  camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000)
  camera.position.z = 50

  // Set up renderer
  renderer = new THREE.WebGLRenderer({ canvas: threeCanvas.value, antialias: true })
  renderer.setSize(window.innerWidth, window.innerHeight)
  renderer.setPixelRatio(window.devicePixelRatio)

  // Add ambient light for soft illumination
  const ambientLight = new THREE.AmbientLight(0x404040, 0.5)
  scene.add(ambientLight)

  // Create glowing spheres
  const sphereGeometry = new THREE.SphereGeometry(2, 32, 32)
  for (let i = 0; i < sphereCount; i++) {
    const material = new THREE.MeshStandardMaterial({
      // color: new THREE.Color(`hsl(${Math.random() * 360}, 70%, 60%)`),
      // emissive: new THREE.Color(`hsl(${Math.random() * 360}, 50%, 50%)`),
      emissiveIntensity: 0.5,
      metalness: 0.2,
      roughness: 0.4
    })
    const sphere = new THREE.Mesh(sphereGeometry, material)
    sphere.position.set(
      (Math.random() - 0.5) * 80,
      (Math.random() - 0.5) * 80,
      (Math.random() - 0.5) * 80
    )
    sphere.userData = {
      rotationSpeed: new THREE.Vector3(
        (Math.random() - 0.5) * 0.01,
        (Math.random() - 0.5) * 0.01,
        (Math.random() - 0.5) * 0.01
      ),
      floatSpeed: Math.random() * 0.05 + 0.02
    }
    scene.add(sphere)
    spheres.push(sphere)

    // Add point light to each sphere for glow effect
    const pointLight = new THREE.PointLight(sphere.material.emissive, 0.8, 20)
    pointLight.position.copy(sphere.position)
    scene.add(pointLight)
  }

  // Create particle system
  const particleGeometry = new THREE.BufferGeometry()
  const positions = new Float32Array(particleCount * 3)
  const colors = new Float32Array(particleCount * 3)
  for (let i = 0; i < particleCount; i++) {
    positions[i * 3] = (Math.random() - 0.5) * 200
    positions[i * 3 + 1] = (Math.random() - 0.5) * 200
    positions[i * 3 + 2] = (Math.random() - 0.5) * 200
    colors[i * 3] = Math.random()
    colors[i * 3 + 1] = Math.random()
    colors[i * 3 + 2] = 1.0
  }
  particleGeometry.setAttribute('position', new THREE.BufferAttribute(positions, 3))
  particleGeometry.setAttribute('color', new THREE.BufferAttribute(colors, 3))
  const particleMaterial = new THREE.PointsMaterial({
    size: 0.5,
    vertexColors: true,
    transparent: true,
    opacity: 0.6
  })
  const particleSystem = new THREE.Points(particleGeometry, particleMaterial)
  scene.add(particleSystem)
  particles.push(particleSystem)

  // Handle window resize
  const onWindowResize = () => {
    camera.aspect = window.innerWidth / window.innerHeight
    camera.updateProjectionMatrix()
    renderer.setSize(window.innerWidth, window.innerHeight)
  }
  window.addEventListener('resize', onWindowResize)

  // Clean up on unmount
  onUnmounted(() => {
    window.removeEventListener('resize', onWindowResize)
    renderer.dispose()
  })
}

// Animation loop
const animate = () => {
  requestAnimationFrame(animate)

  // Animate spheres
  spheres.forEach(sphere => {
    sphere.rotation.x += sphere.userData.rotationSpeed.x
    sphere.rotation.y += sphere.userData.rotationSpeed.y
    sphere.rotation.z += sphere.userData.rotationSpeed.z
    sphere.position.y += Math.sin(Date.now() * 0.001 + sphere.position.x) * sphere.userData.floatSpeed
    if (sphere.position.y > 50) sphere.position.y -= 100
    if (sphere.position.y < -50) sphere.position.y += 100
  })

  // Animate particles
  particles.forEach(particleSystem => {
    particleSystem.rotation.y += 0.002
    const positions = particleSystem.geometry.attributes.position.array
    for (let i = 0; i < particleCount; i++) {
      positions[i * 3 + 2] += 0.05
      if (positions[i * 3 + 2] > 100) positions[i * 3 + 2] -= 200
    }
    particleSystem.geometry.attributes.position.needsUpdate = true
  })

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