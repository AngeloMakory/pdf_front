<template>
  <div class="pdf-uploader">
    <h2>Upload PDF for Summarization</h2>
    
    <form @submit.prevent="postMessage" class="upload-form">
      <div class="file-input-container">
        <input 
          type="file" 
          @change="onFileChange" 
          accept="application/pdf" 
          ref="fileInput"
          :disabled="isUploading"
        />
        <div v-if="selectedFile" class="file-info">
          Selected: {{ selectedFile.name }} ({{ formatFileSize(selectedFile.size) }})
        </div>
      </div>
      
      <button 
        type="submit" 
        :disabled="!selectedFile || isUploading"
        class="upload-btn"
      >
        {{ isUploading ? 'Processing...' : 'Upload & Summarize' }}
      </button>
    </form>

    <div v-if="error" class="error-message">
      {{ error }}
    </div>

    <div v-if="messages.length > 0" class="summaries-section">
      <h3>PDF Summaries</h3>
      <div class="summaries-list">
        <div 
          v-for="msg in messages" 
          :key="msg.id" 
          class="summary-item"
        >
          <div class="summary-header">
            <strong>{{ msg.filename }}</strong>
            <span class="upload-date">{{ formatDate(msg.createdAt) }}</span>
          </div>
          <div class="summary-content">
            {{ msg.summary || 'Processing...' }}
          </div>
          <div v-if="msg.metadata" class="metadata">
            <small>
              Pages: {{ msg.metadata.pages }} | 
              Words: {{ msg.metadata.wordCount }} |
              Summary ratio: {{ msg.metadata.compressionRatio }}%
            </small>
          </div>
        </div>
      </div>
    </div>

    <div v-else-if="!isLoading" class="no-summaries">
      No PDFs uploaded yet. Upload your first PDF to get started!
    </div>

    <div v-if="isLoading" class="loading">
      Loading summaries...
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'

const messages = ref([])
const selectedFile = ref(null)
const isUploading = ref(false)
const isLoading = ref(false)
const error = ref(null)
const fileInput = ref(null)

const onFileChange = (event) => {
  selectedFile.value = event.target.files[0]
  error.value = null
  
  // Validate file size (e.g., max 10MB)
  if (selectedFile.value && selectedFile.value.size > 10 * 1024 * 1024) {
    error.value = 'File size must be less than 10MB'
    selectedFile.value = null
    return
  }
}

const fetchMessages = async () => {
  try {
    isLoading.value = true
    const res = await axios.get('http://localhost:5000/api/pdfs')
    messages.value = res.data
  } catch (err) {
    error.value = 'Failed to load summaries'
    console.error('Fetch error:', err)
  } finally {
    isLoading.value = false
  }
}

const postMessage = async () => {
  if (!selectedFile.value) {
    error.value = "Please select a PDF file"
    return
  }

  try {
    isUploading.value = true
    error.value = null

    const formData = new FormData()
    formData.append('file', selectedFile.value)

    const res = await axios.post('http://localhost:5000/api/pdfs', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
      timeout: 60000 // 60 second timeout for large files
    })

    console.log('Upload successful:', res.data)
    
    // Clear the file input
    selectedFile.value = null
    if (fileInput.value) {
      fileInput.value.value = ''
    }
    
    // Refresh the list
    await fetchMessages()
    
  } catch (err) {
    error.value = err.response?.data?.message || 'Upload failed. Please try again.'
    console.error('Upload error:', err)
  } finally {
    isUploading.value = false
  }
}

const formatFileSize = (bytes) => {
  if (bytes === 0) return '0 Bytes'
  const k = 1024
  const sizes = ['Bytes', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  return new Date(dateString).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

onMounted(fetchMessages)
</script>

<style scoped>
.pdf-uploader {
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}

.upload-form {
  background: #f8f9fa;
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 20px;
  border: 2px dashed #dee2e6;
}

.file-input-container {
  margin-bottom: 15px;
}

.file-info {
  margin-top: 8px;
  padding: 8px;
  background: #e9ecef;
  border-radius: 4px;
  font-size: 14px;
  color: #6c757d;
}

.upload-btn {
  background: #007bff;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 16px;
  transition: background-color 0.2s;
}

.upload-btn:hover:not(:disabled) {
  background: #0056b3;
}

.upload-btn:disabled {
  background: #6c757d;
  cursor: not-allowed;
}

.error-message {
  background: #f8d7da;
  color: #721c24;
  padding: 12px;
  border-radius: 4px;
  margin-bottom: 20px;
  border: 1px solid #f5c6cb;
}

.summaries-section h3 {
  margin-bottom: 15px;
  color: #333;
}

.summaries-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.summary-item {
  background: white;
  border: 1px solid #dee2e6;
  border-radius: 8px;
  padding: 16px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.summary-header {
  display: flex;
  justify-content: between;
  align-items: center;
  margin-bottom: 10px;
}

.upload-date {
  font-size: 12px;
  color: #6c757d;
}

.summary-content {
  line-height: 1.5;
  margin-bottom: 10px;
  color: #333;
}

.metadata {
  color: #6c757d;
  border-top: 1px solid #e9ecef;
  padding-top: 8px;
}

.no-summaries {
  text-align: center;
  color: #6c757d;
  padding: 40px;
  background: #f8f9fa;
  border-radius: 8px;
}

.loading {
  text-align: center;
  padding: 20px;
  color: #6c757d;
}

/* Responsive design */
@media (max-width: 600px) {
  .pdf-uploader {
    padding: 10px;
  }
  
  .summary-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 5px;
  }
}
</style>