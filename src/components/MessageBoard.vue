<template>
  <div>
    <h2>Messages</h2>
    <form @submit.prevent="postMessage">
      <input v-model="newMessage" placeholder="Type a message" />
      <button type="submit">Send</button>
    </form>
    <ul>
      <li v-for="msg in messages" :key="msg.id">{{ msg.content }}</li>
    </ul>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'

const messages = ref([])
const newMessage = ref('')

const fetchMessages = async () => {
  const res = await axios.get('http://localhost:5001/api/pdfs') // <- change
  messages.value = res.data
}

const postMessage = async () => {
  const file = new FormData()
  file.append('file', new Blob(['Dummy PDF Content'], { type: 'application/pdf' }), 'sample.pdf')

  await axios.post('http://localhost:5001/api/pdfs', file, {
    headers: { 'Content-Type': 'multipart/form-data' }
  })

  fetchMessages()
}

onMounted(fetchMessages)
</script>
