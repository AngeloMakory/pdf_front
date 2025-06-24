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
  const res = await axios.get('http://localhost:5000/api/messages')
  messages.value = res.data
}

const postMessage = async () => {
  if (!newMessage.value.trim()) return
  await axios.post('http://localhost:5000/api/messages', { content: newMessage.value })
  newMessage.value = ''
  fetchMessages()
}

onMounted(fetchMessages)
</script>
