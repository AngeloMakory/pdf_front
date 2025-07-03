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
    console.log('Fetched messages:', res.data)
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

    console.log('Uploading file:', selectedFile.value.name)

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
    error.value = err.response?.data?.error || 'Upload failed. Please try again.'
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

onMounted(() => {
  console.log('Component mounted, fetching messages...')
  fetchMessages()
})
</script>

<template>
  <div class="app">
    <header class="app-header">
      <h1>PDF ASSISTANT</h1>
    </header>
    
    <main class="app-main">
      <div class="pdf-uploader">
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
    </main>
    
    <footer class="app-footer">
      <p>&copy; Powered By <div class="angelo"><b>ANGELO MAKORY</b></div></p>
    </footer>
  </div>
</template>

<style scoped>
.angelo{
  color: #ff0000;
}
.app {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: #00aeff ;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}

.app-header {
  text-align: center;
  padding: 2rem 1rem;
  color: white;
  background: rgba(0, 0, 0, 0.1);
  backdrop-filter: blur(10px);
}

.app-header h1 {
  font-size: 2.5rem;
  margin: 0 0 0.5rem 0;
  font-weight: 700;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
}

.app-header p {
  font-size: 1.1rem;
  margin: 0;
  opacity: 0.9;
}

.app-main {
  flex: 1;
  padding: 2rem 1rem;
  display: flex;
  justify-content: center;
  align-items: flex-start;
}

.pdf-uploader {
  max-width: 800px;
  width: 100%;
  background: white;
  border-radius: 12px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
  padding: 2rem;
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
  padding: 12px 24px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 16px;
  font-weight: 500;
  transition: all 0.2s;
  min-width: 180px;
}

.upload-btn:hover:not(:disabled) {
  background: #0056b3;
  transform: translateY(-1px);
}

.upload-btn:disabled {
  background: #6c757d;
  cursor: not-allowed;
  transform: none;
}

.error-message {
  background: #f8d7da;
  color: #721c24;
  padding: 12px;
  border-radius: 6px;
  margin-bottom: 20px;
  border: 1px solid #f5c6cb;
}

.summaries-section h3 {
  margin-bottom: 15px;
  color: #333;
  font-size: 1.4rem;
}

.summaries-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.summary-item {
  background: #f8f9fa;
  border: 1px solid #dee2e6;
  border-radius: 8px;
  padding: 16px;
  transition: all 0.2s;
}

.summary-item:hover {
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.summary-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.upload-date {
  font-size: 12px;
  color: #6c757d;
}

.summary-content {
  line-height: 1.6;
  margin-bottom: 10px;
  color: #333;
}

.metadata {
  color: #6c757d;
  border-top: 1px solid #e9ecef;
  padding-top: 8px;
  font-size: 0.9rem;
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

.app-footer {
  text-align: center;
  padding: 1rem;
  color: white;
  background: rgba(0, 0, 0, 0.1);
  backdrop-filter: blur(10px);
  opacity: 0.8;
}

.app-footer p {
  margin: 0;
  font-size: 0.9rem;
}

/* Responsive design */
@media (max-width: 768px) {
  .app-header h1 {
    font-size: 2rem;
  }
  
  .app-header p {
    font-size: 1rem;
  }
  
  .app-main {
    padding: 1rem;
  }
}
</style>