// Sample user database (in production, this would be on a server)
const users = {
    'student1': { password: 'password123', role: 'student', name: 'John Smith' },
    'teacher1': { password: 'password123', role: 'teacher', name: 'Mr. Johnson' },
    'parent1': { password: 'password123', role: 'parent', name: 'Mary Smith' }
};

// Handle Login
function handleLogin(event) {
    event.preventDefault();
    
    const userType = document.getElementById('userType').value;
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
    
    if (!userType) {
        alert('Please select a user type');
        return;
    }
    
    // Check if user exists
    if (users[username] && users[username].password === password && users[username].role === userType) {
        // Store user info in session storage
        sessionStorage.setItem('currentUser', JSON.stringify({
            username: username,
            role: userType,
            name: users[username].name
        }));
        
        // Redirect based on user role
        if (userType === 'student') {
            window.location.href = 'student-dashboard.html';
        } else if (userType === 'teacher') {
            window.location.href = 'teacher-dashboard.html';
        } else if (userType === 'parent') {
            window.location.href = 'parent-dashboard.html';
        }
    } else {
        alert('Invalid username, password, or user type. Please try again.\n\nDemo credentials:\nstudent1 / password123\nteacher1 / password123\nparent1 / password123');
    }
}

// Handle Signup
function handleSignup(event) {
    event.preventDefault();
    
    const userType = document.getElementById('userType').value;
    const fullName = document.getElementById('fullName').value;
    const email = document.getElementById('email').value;
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
    const confirmPassword = document.getElementById('confirmPassword').value;
    
    if (!userType) {
        alert('Please select a user type');
        return;
    }
    
    if (password !== confirmPassword) {
        alert('Passwords do not match');
        return;
    }
    
    if (password.length < 6) {
        alert('Password must be at least 6 characters long');
        return;
    }
    
    if (users[username]) {
        alert('Username already exists. Please choose another one.');
        return;
    }
    
    // Add new user
    users[username] = {
        password: password,
        role: userType,
        name: fullName
    };
    
    alert('Account created successfully! Please log in.');
    window.location.href = 'login.html';
}

// Logout function
function logout() {
    sessionStorage.removeItem('currentUser');
    window.location.href = 'index.html';
}

// Check if user is logged in
function checkAuth() {
    const user = JSON.parse(sessionStorage.getItem('currentUser'));
    if (!user) {
        window.location.href = 'login.html';
        return null;
    }
    return user;
}

// Auto-check on page load for protected pages
window.addEventListener('load', () => {
    if (window.location.href.includes('dashboard')) {
        const user = checkAuth();
        if (user) {
            // Update user name in dashboard
            const nameElement = document.getElementById('studentName') || 
                              document.getElementById('teacherName') || 
                              document.getElementById('parentName');
            if (nameElement) {
                nameElement.textContent = user.name;
            }
        }
    }
});