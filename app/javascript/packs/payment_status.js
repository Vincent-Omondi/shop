class PaymentStatusPoller {
  constructor(checkoutRequestId) {
    this.checkoutRequestId = checkoutRequestId;
    this.pollCount = 0;
    this.maxPolls = 180; // 3 minutes total (1 second × 180)
    this.statusElement = document.getElementById('payment-status');
    this.notificationElement = document.querySelector('.notification');
    this.isPolling = false;
  }
  start() {
    if (this.isPolling) return;
    this.isPolling = true;
    
    // Check immediately
    this.checkStatus();
    // Poll every 1 second instead 
    this.pollInterval = setInterval(() => this.checkStatus(), 1000);
    
    // Clear interval when leaving the page
    document.addEventListener('turbolinks:before-visit', () => {
      this.stop();
    });
  }

  stop() {
    if (this.pollInterval) {
      clearInterval(this.pollInterval);
      this.isPolling = false;
    }
  }

  async checkStatus() {
    this.pollCount++;
    
    if (this.pollCount >= this.maxPolls) {
      this.stop();
      return;
    }

    try {
      const response = await fetch('/stkquery', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({ CheckoutRequestID: this.checkoutRequestId })
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      
      if (data.success) {
        this.updateStatus(data.data);
      }
    } catch (error) {
      console.error('Error checking payment status:', error);
    }
  }

  updateStatus(data) {
    if (!this.statusElement) return;

    if (data.ResultCode === 0) {
      this.statusElement.textContent = 'Completed';
      this.statusElement.classList.remove('is-warning');
      this.statusElement.classList.add('is-success');
      
      this.notificationElement.classList.remove('is-info');
      this.notificationElement.classList.add('is-success');
      this.notificationElement.innerHTML = `
        <h2 class="title">Payment Successful!</h2>
        <p>Your payment has been received and your order is being processed.</p>
        <p>You will receive a confirmation email shortly.</p>
        <div class="mt-4">
          <a href="/" class="button is-primary">Continue Shopping</a>
        </div>
      `;
      
      this.stop();
    } else if (data.ResultCode === 1) {
      this.statusElement.textContent = 'Failed';
      this.statusElement.classList.remove('is-warning');
      this.statusElement.classList.add('is-danger');
      
      this.notificationElement.classList.remove('is-info');
      this.notificationElement.classList.add('is-danger');
      this.notificationElement.innerHTML = `
        <h2 class="title">Payment Failed</h2>
        <p>We were unable to process your payment. Please try again.</p>
        <div class="mt-4">
          <a href="/checkouts/new" class="button is-primary">Try Again</a>
          <a href="/" class="button is-light">Return to Shop</a>
        </div>
      `;
      
      this.stop();
    }
  }
}

// Initialize poller when the page loads
document.addEventListener('turbolinks:load', () => {
  const checkoutRequestId = document.getElementById('checkout-request-id')?.value;
  if (checkoutRequestId) {
    const poller = new PaymentStatusPoller(checkoutRequestId);
    poller.start();
  }
});

// Cleanup when navigating away
document.addEventListener('turbolinks:before-visit', () => {
  if (window.currentPoller) {
    window.currentPoller.stop();
  }
});

window.PaymentStatusPoller = PaymentStatusPoller; 
