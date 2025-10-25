// Session management for admin users
// Handles auto-logout warning and session extension

class AdminSessionManager {
  constructor() {
    this.timeoutDuration = 30 * 60 * 1000; // 30 minutes in milliseconds
    this.warningTime = 5 * 60 * 1000; // Show warning 5 minutes before timeout
    this.checkInterval = 60 * 1000; // Check every minute
    this.lastActivity = Date.now();
    
    this.init();
  }
  
  init() {
    // Only initialize if we're on an admin page
    if (!document.body.classList.contains('admin-page')) {
      return;
    }
    
    this.bindEvents();
    this.startActivityCheck();
  }
  
  bindEvents() {
    // Track user activity
    const events = ['mousedown', 'mousemove', 'keypress', 'scroll', 'touchstart', 'click'];
    
    events.forEach(event => {
      document.addEventListener(event, () => {
        this.updateActivity();
      }, true);
    });
  }
  
  updateActivity() {
    this.lastActivity = Date.now();
    this.hideWarning();
  }
  
  startActivityCheck() {
    setInterval(() => {
      this.checkSession();
    }, this.checkInterval);
  }
  
  checkSession() {
    const now = Date.now();
    const timeSinceActivity = now - this.lastActivity;
    const timeUntilTimeout = this.timeoutDuration - timeSinceActivity;
    
    if (timeUntilTimeout <= 0) {
      this.logout();
    } else if (timeUntilTimeout <= this.warningTime) {
      this.showWarning(Math.ceil(timeUntilTimeout / 1000 / 60));
    }
  }
  
  showWarning(minutesLeft) {
    // Remove existing warning if present
    this.hideWarning();
    
    const warning = document.createElement('div');
    warning.id = 'session-warning';
    warning.className = 'alert alert-warning position-fixed top-0 start-50 translate-middle-x mt-3';
    warning.style.zIndex = '9999';
    warning.style.minWidth = '400px';
    
    warning.innerHTML = `
      <div class="d-flex align-items-center justify-content-between">
        <div>
          <i class="fas fa-clock me-2"></i>
          <strong>Session Timeout Warning</strong>
          <br>
          <small>Your session will expire in ${minutesLeft} minute(s). Click "Stay Logged In" to continue.</small>
        </div>
        <div>
          <button type="button" class="btn btn-primary btn-sm me-2" onclick="adminSessionManager.extendSession()">
            Stay Logged In
          </button>
          <button type="button" class="btn btn-outline-secondary btn-sm" onclick="adminSessionManager.logout()">
            Logout Now
          </button>
        </div>
      </div>
    `;
    
    document.body.appendChild(warning);
  }
  
  hideWarning() {
    const warning = document.getElementById('session-warning');
    if (warning) {
      warning.remove();
    }
  }
  
  extendSession() {
    // Make a request to extend the session
    fetch('/admin/extend_session', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      }
    }).then(response => {
      if (response.ok) {
        this.updateActivity();
        this.showSuccessMessage('Session extended successfully!');
      } else {
        this.logout();
      }
    }).catch(() => {
      this.logout();
    });
  }
  
  showSuccessMessage(message) {
    const success = document.createElement('div');
    success.className = 'alert alert-success position-fixed top-0 start-50 translate-middle-x mt-3';
    success.style.zIndex = '9999';
    success.innerHTML = `<i class="fas fa-check me-2"></i>${message}`;
    
    document.body.appendChild(success);
    
    setTimeout(() => {
      success.remove();
    }, 3000);
  }
  
  logout() {
    this.hideWarning();
    
    // Show logout message
    const logoutMsg = document.createElement('div');
    logoutMsg.className = 'alert alert-info position-fixed top-0 start-50 translate-middle-x mt-3';
    logoutMsg.style.zIndex = '9999';
    logoutMsg.innerHTML = '<i class="fas fa-sign-out-alt me-2"></i>Session expired. Redirecting to login...';
    
    document.body.appendChild(logoutMsg);
    
    // Redirect to logout
    setTimeout(() => {
      window.location.href = '/admin_users/sign_out';
    }, 2000);
  }
}

// Export the class as default export
export default AdminSessionManager;

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
  if (typeof window.adminSessionManager === 'undefined') {
    window.adminSessionManager = new AdminSessionManager();
  }
});
