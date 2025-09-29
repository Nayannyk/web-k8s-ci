document.getElementById('msg').innerText = 'This page served from a Docker container on Kubernetes (Minikube).';
document.getElementById('btn').addEventListener('click', () => {
  alert('Kubernetes se pyaar karo! ❤️ — याद रखो: Pod = Flat, Service = Gate 🚪');
});

