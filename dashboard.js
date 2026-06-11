// Get current logged in user
function getCurrentUser() {
    const user = JSON.parse(sessionStorage.getItem('currentUser'));
    if (!user) {
        window.location.href = 'login.html';
    }
    return user;
}

// Show/Hide sections in dashboard
function showSection(sectionId) {
    // Hide all sections
    const sections = document.querySelectorAll('.section-content');
    sections.forEach(section => {
        section.classList.remove('visible');
        section.classList.add('hidden');
    });
    
    // Show selected section
    const selectedSection = document.getElementById(sectionId);
    if (selectedSection) {
        selectedSection.classList.remove('hidden');
        selectedSection.classList.add('visible');
    }
}

// Initialize dashboard on load
window.addEventListener('load', () => {
    const user = getCurrentUser();
    
    if (user) {
        // Update user name
        const nameElements = document.querySelectorAll('#studentName, #teacherName, #parentName, #fullName, #childName');
        nameElements.forEach(el => {
            if (el) el.textContent = user.name;
        });
        
        // Show overview section by default
        showSection('overview');
    }
});

// Load class attendance
function loadAttendance() {
    const className = document.getElementById('attendanceClass').value;
    alert(`Loaded attendance for ${className}`);
}

// View class details
function viewClassDetails(className) {
    alert(`Viewing details for Class ${className}`);
}

// Send message to teacher
function sendMessage(teacherName) {
    const message = prompt(`Type your message for ${teacherName}:`);
    if (message) {
        alert(`Message sent to ${teacherName}: "${message}"`);
    }
}

// Logout function
function logout() {
    sessionStorage.removeItem('currentUser');
    window.location.href = 'index.html';
}

// Assignment form submission
const assignmentForm = document.getElementById('assignmentForm');
if (assignmentForm) {
    assignmentForm.addEventListener('submit', (e) => {
        e.preventDefault();
        const title = document.getElementById('assignmentTitle').value;
        const dueDate = document.getElementById('dueDate').value;
        alert(`Assignment "${title}" created successfully with due date: ${dueDate}`);
        assignmentForm.reset();
    });
}