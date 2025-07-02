<script setup>
import MessageBoard from './components/MessageBoard.vue';
import HelloWorld from './components/HelloWorld.vue'
import TheWelcome from './components/TheWelcome.vue'
</script>

<template>
  <div class="pdf-summary-app">
    <h1>PDF Summary Generator</h1>
    
    <div class="upload-section">
      <input 
        type="file" 
        id="pdf-upload" 
        accept=".pdf" 
        @change="handleFileUpload"
        ref="fileInput"
      >
      <label for="pdf-upload" class="upload-btn">
        {{ selectedFile ? selectedFile.name : 'Choose PDF File' }}
      </label>
      
      <button 
        @click="submitPDF" 
        :disabled="!selectedFile || isProcessing"
        class="submit-btn"
      >
        {{ isProcessing ? 'Processing...' : 'Get Summary' }}
      </button>
    </div>
    
    <div v-if="summary" class="summary-section">
      <h3>Summary:</h3>
      <div class="summary-output">{{ summary }}</div>
    </div>
    
    <div v-if="error" class="error-message">
      {{ error }}
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      selectedFile: null,
      summary: '',
      error: '',
      isProcessing: false
    }
  },
  methods: {
    handleFileUpload(event) {
      const file = event.target.files[0];
      if (file && file.type === 'application/pdf') {
        this.selectedFile = file;
        this.error = '';
      } else {
        this.error = 'Please select a valid PDF file.';
        this.selectedFile = null;
      }
    },
    async submitPDF() {
      if (!this.selectedFile) return;
      
      this.isProcessing = true;
      this.error = '';
      
      try {
        // Here you would typically send the PDF to your backend
        // For now, we'll simulate a response
        await new Promise(resolve => setTimeout(resolve, 1500));
        
        // Mock summary - in a real app, this would come from your API
        this.summary = `This is a generated summary of "${this.selectedFile.name}". 
        The PDF contains approximately 10 pages covering topics related to web development. 
        Key points include Vue 3 composition API, component structure, and state management.`;
        
      } catch (err) {
        this.error = 'Failed to process PDF. Please try again.';
      } finally {
        this.isProcessing = false;
      }
    }
  }
}
</script>

<style scoped>
.pdf-summary-app {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem;
  font-family: Arial, sans-serif;
}

.upload-section {
  display: flex;
  gap: 1rem;
  margin: 2rem 0;
  align-items: center;
}

#pdf-upload {
  display: none;
}

.upload-btn {
  padding: 0.75rem 1.5rem;
  background-color: #f0f0f0;
  border: 1px solid #ccc;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.2s;
}

.upload-btn:hover {
  background-color: #e0e0e0;
}

.submit-btn {
  padding: 0.75rem 1.5rem;
  background-color: #42b983;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.2s;
}

.submit-btn:hover:not(:disabled) {
  background-color: #3aa876;
}

.submit-btn:disabled {
  background-color: #cccccc;
  cursor: not-allowed;
}

.summary-section {
  margin-top: 2rem;
  padding: 1rem;
  border: 1px solid #eee;
  border-radius: 4px;
  background-color: #f9f9f9;
}

.summary-output {
  white-space: pre-wrap;
  margin-top: 1rem;
  line-height: 1.6;
}

.error-message {
  color: #ff4444;
  margin-top: 1rem;
}
</style>