<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartcampus.model.User" %>
<%
    // Redirect to dashboard if already logged in
    HttpSession existingSession = request.getSession(false);
    if (existingSession != null && existingSession.getAttribute("loggedInUser") != null) {
        User existingUser = (User) existingSession.getAttribute("loggedInUser");
        String dashPath = request.getContextPath() + "/" + existingUser.getRole().name() + "/dashboard";
        response.sendRedirect(dashPath);
        return;
    }
    // Login error/email from LoginServlet
    String errorMessage = (String) request.getAttribute("error");
    String emailValue   = (String) request.getAttribute("emailValue");
    // Registration error/success
    String registerError = (String) request.getAttribute("registerError");
    String activeTab = (String) request.getAttribute("activeTab");  // "signin" or "signup"
    // Success message from session (set by RegisterServlet after successful registration)
    String registerSuccess = null;
    HttpSession sess = request.getSession(false);
    if (sess != null) {
        registerSuccess = (String) sess.getAttribute("registerSuccess");
        if (registerSuccess != null) sess.removeAttribute("registerSuccess");
    }
    // Default active tab
    if (activeTab == null) {
        activeTab = (registerError != null) ? "signup" : "signin";
    }
    // Re-fill registration form values after error
    String regName       = request.getAttribute("regName")       != null ? (String) request.getAttribute("regName")       : "";
    String regEmail      = request.getAttribute("regEmail")      != null ? (String) request.getAttribute("regEmail")      : "";
    String regPhone      = request.getAttribute("regPhone")      != null ? (String) request.getAttribute("regPhone")      : "";
    String regGender     = request.getAttribute("regGender")     != null ? (String) request.getAttribute("regGender")     : "";
    String regRole       = request.getAttribute("regRole")       != null ? (String) request.getAttribute("regRole")       : "lecturer";
    String regDepartment = request.getAttribute("regDepartment") != null ? (String) request.getAttribute("regDepartment") : "";
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
    <title>SmartCampus | Egerton University - Facility Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        :root {
            --egerton-green: #00A651;
            --egerton-green-dark: #008a43;
            --egerton-green-deep: #007624;
            --egerton-gold: #D2AC67;
            --card-bg: rgba(255, 255, 255, 0.96);
            --input-bg: rgba(248, 249, 250, 0.95);
            --text-dark: #1F2A3A;
            --text-muted: #5a6e8a;
            --shadow-sm: 0 8px 20px -6px rgba(0, 0, 0, 0.15);
        }

       body {
            font-family: 'Inter', sans-serif;
            margin: 0;
            padding: 0;
            height: 100vh;
            width: 100%;
            overflow-x: hidden;
        }
        
        .auth-wrapper {
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            width: 100%;
            padding: 12px;
            position: relative;
            z-index: 3;
            flex-direction: column;
        }

        .slideshow-container {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100vh;
            z-index: -2;   /* background */
        }

        .slide {
            position: absolute;
            width: 100%;
            height: 100%;
            background-size: cover;
            background-position: center;
            opacity: 0;
            transition: opacity 1.5s ease-in-out;
        }

        .slide.active {
            opacity: 1;
        }

        .background-overlay {
            position: fixed;
            width: 100%;
            height: 100%;
            z-index: -1;   /* overlay above image */
        }

        .corporate-green-bar {
            position: fixed;
            bottom: 0;
            left: 0;
            width: 100%;
            height: 50px;
            background: var(--egerton-green);
            z-index: 2;
            box-shadow: 0 -4px 20px rgba(0, 0, 0, 0.2);
            overflow: hidden;
        }

        .scrolling-text {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            display: flex;
            align-items: center;
            overflow: hidden;
            white-space: nowrap;
        }

        .scrolling-content {
            display: inline-block;
            animation: scroll-left 60s linear infinite;
            font-family: 'Inter', sans-serif;
            font-size: 1.5rem;
            font-weight: 600;
            color: white;
            letter-spacing: 0.5px;
            will-change: transform;
        }

        .scrolling-content span {
            display: inline-block;
            margin: 0 50px;
        }

        .scrolling-content strong {
            font-weight: 800;
            color: var(--egerton-gold);
            margin-right: 8px;
            font-size: 1.9rem;
        }

        .separator {
            display: inline-block;
            width: 3px;
            height: 35px;
            background: rgba(255, 255, 255, 0.5);
            margin: 0 30px;
            vertical-align: middle;
        }

        @keyframes scroll-left {
            0% { transform: translateX(0); }
            100% { transform: translateX(-50%); }
        }

        .main-container {
            width: 100%;
            max-width: 520px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            margin: auto;
            gap: 16px;
        }

        .header-section {
            text-align: center;
            margin-bottom: 8px;
        }

        .header-section h1 {
            font-family: 'Playfair Display', serif;
            font-size: 1.5rem;
            font-weight: 800;
            color: white;
            text-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
            margin-bottom: 0px;
        }

        .header-section p {
            font-weight: 500;
            font-size: 0.65rem;
            opacity: 0.95;
            color: #fff9ef;
            background: rgba(0, 0, 0, 0.4);
            display: inline-block;
            padding: 2px 10px;
            border-radius: 30px;
        }

        .auth-tabs {
            display: flex;
            gap: 10px;
            margin-bottom: 16px;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 50px;
            padding: 4px;
        }

        .tab-btn {
            flex: 1;
            background: transparent;
            border: none;
            padding: 10px 20px;
            border-radius: 40px;
            font-weight: 600;
            font-size: 0.9rem;
            color: white;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .tab-btn.active {
            background: var(--egerton-green);
            color: white;
            box-shadow: 0 2px 8px rgba(0,0,0,0.2);
        }

        .tab-btn:not(.active):hover {
            background: rgba(255,255,255,0.2);
        }

        .auth-card {
            background: var(--card-bg);
            border-radius: 20px;
            padding: 30px 32px;
            box-shadow: var(--shadow-sm);
            width: 100%;
            max-width: 480px;
            border: 1px solid rgba(255, 255, 255, 0.3);
            /* Remove inner scroll */
            max-height: none;
            overflow: visible;
            transition: all 0.3s ease;
        }

        .auth-card::-webkit-scrollbar {
            width: 5px;
        }

        .auth-card::-webkit-scrollbar-track {
            background: #f1f1f1;
            border-radius: 5px;
        }

        .auth-card::-webkit-scrollbar-thumb {
            background: var(--egerton-green);
            border-radius: 5px;
        }

        .auth-card h2 {
            font-family: 'Playfair Display', serif;
            font-size: 1.3rem;
            font-weight: 700;
            text-align: center;
            margin-bottom: 16px;
            background: linear-gradient(135deg, #1e4620, #00A651);
            background-clip: text;
            -webkit-background-clip: text;
            color: transparent;
        }

        .form-group {
            margin-bottom: 18px;
        }

        .form-label {
            font-weight: 600;
            color: var(--text-dark);
            font-size: 0.7rem;
            margin-bottom: 4px;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .form-label i {
            color: var(--egerton-green);
            font-size: 0.75rem;
        }

        .form-label .required {
            color: #dc3545;
            font-size: 0.7rem;
        }

        .form-control, .form-select {
            background-color: var(--input-bg);
            border: 1.5px solid #e9ecef;
            padding: 8px 12px;
            border-radius: 12px;
            font-size: 0.85rem;
            font-weight: 500;
            color: #1f2a3a;
            transition: all 0.2s;
            width: 100%;
        }

        .form-control:focus, .form-select:focus {
            background-color: #ffffff;
            border-color: var(--egerton-green);
            box-shadow: 0 0 0 3px rgba(0, 166, 81, 0.12);
            outline: none;
        }

        .form-control.is-invalid, .form-select.is-invalid {
            border-color: #dc3545;
            background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 12 12' width='12' height='12' fill='none' stroke='%23dc3545'%3e%3ccircle cx='6' cy='6' r='4.5'/%3e%3cpath stroke-linecap='round' d='M5.8 3.6h.4L6 6.5z'/%3e%3ccircle cx='6' cy='8.2' r='.6' fill='%23dc3545' stroke='none'/%3e%3c/svg%3e");
            background-repeat: no-repeat;
            background-position: right calc(0.375em + 0.1875rem) center;
            background-size: calc(0.75em + 0.375rem) calc(0.75em + 0.375rem);
        }

        .form-control.is-valid, .form-select.is-valid {
            border-color: #00A651;
            background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 8 8'%3e%3cpath fill='%2300A651' d='M2.3 6.73L.6 4.53c-.4-1.04.46-1.4 1.1-.8l1.1 1.4 3.4-3.8c.6-.63 1.6-.27 1.2.7l-4 4.6c-.43.5-.8.4-1.1.1z'/%3e%3c/svg%3e");
            background-repeat: no-repeat;
            background-position: right calc(0.375em + 0.1875rem) center;
            background-size: calc(0.75em + 0.375rem) calc(0.75em + 0.375rem);
        }

        .error-message {
            font-size: 0.7rem;
            margin-top: 4px;
        }

        .btn-auth {
            background: linear-gradient(105deg, var(--egerton-green-dark), var(--egerton-green));
            color: white;
            width: 100%;
            padding: 8px;
            border-radius: 40px;
            border: none;
            font-weight: 700;
            font-size: 0.85rem;
            transition: all 0.2s;
            margin-top: 12px;
            box-shadow: 0 2px 6px rgba(0, 118, 36, 0.2);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        .btn-auth:hover {
            background: linear-gradient(105deg, #006622, #008f45);
            transform: translateY(-1px);
            box-shadow: 0 4px 10px rgba(0, 80, 30, 0.25);
        }

        .form-footer {
            margin-top: 16px;
            text-align: center;
            font-size: 0.7rem;
            color: var(--text-muted);
        }

        .form-footer a {
            color: var(--egerton-green);
            text-decoration: none;
            font-weight: 600;
        }

        .password-strength {
            margin-top: 6px;
            font-size: 0.65rem;
        }

        .strength-bar {
            height: 3px;
            border-radius: 3px;
            margin-top: 4px;
            transition: all 0.3s;
        }

        .terms-check {
            display: flex;
            align-items: center;
            gap: 8px;
            margin: 12px 0;
            font-size: 0.7rem;
        }

        .terms-check input {
            width: 16px;
            height: 16px;
            accent-color: var(--egerton-green);
        }

        .footer-note {
            margin-top: 10px;
            font-size: 0.55rem;
            color: rgba(255, 255, 240, 0.9);
            text-align: center;
        }

        .role-fields-section {
            border-top: 1px dashed #e0e0e0;
            margin-top: 14px;
            padding-top: 14px;
        }

        .role-fields-title {
            font-size: 0.7rem;
            font-weight: 600;
            color: var(--egerton-green);
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .slideshow-dots {
            position: fixed;
            bottom: 60px;
            left: 50%;
            transform: translateX(-50%);
            display: flex;
            gap: 8px;
            z-index: 3;
        }

        .dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.5);
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .dot.active {
            background: var(--egerton-gold);
            width: 20px;
            border-radius: 4px;
        }

        .alert-custom {
            background-color: rgba(248, 215, 218, 0.98);
            border: 1px solid #f5c6cb;
            color: #721c24;
            border-radius: 10px;
            padding: 8px 12px;
            font-size: 0.7rem;
            margin-top: 12px;
            display: none;
            align-items: center;
            gap: 8px;
        }

        @media (max-width: 768px) {
            .main-container { max-width: 100%; margin-bottom: 60px; }
            .auth-card { padding: 18px 20px; max-height: 70vh; }
            .scrolling-content { font-size: 0.9rem; animation: scroll-left 40s linear infinite; }
            .scrolling-content strong { font-size: 1rem; }
            .separator { height: 20px; margin: 0 15px; }
        }

        @keyframes slideIn {
            from { transform: translateX(100%); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }

        @keyframes slideOut {
            from { transform: translateX(0); opacity: 1; }
            to { transform: translateX(100%); opacity: 0; }
        }
        
        @media (max-width: 768px) {
            .auth-card {
                padding: 24px 20px;
                width: 100%;
                margin: 0 12px;
            }

            .form-group {
                margin-bottom: 16px;
            }
        }

        .custom-toast {
            position: fixed;
            bottom: 70px;
            right: 20px;
            padding: 8px 16px;
            border-radius: 12px;
            font-size: 0.75rem;
            font-weight: 500;
            z-index: 9999;
            animation: slideIn 0.3s ease;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .demo-section {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 18px;
            padding: 10px 16px 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            width: 100%;
            border: 1px solid rgba(210, 172, 103, 0.4);
            margin-top: 14px;
        }
        .demo-title {
            color: var(--egerton-green-deep);
            font-size: 0.65rem;
            font-weight: 700;
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 1px;
            display: flex;
            align-items: center;
            gap: 5px;
            justify-content: center;
        }
        .demo-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 6px;
        }
        .demo-item {
            background: rgba(241, 245, 249, 0.98);
            padding: 5px 8px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            border: 1px solid transparent;
            transition: all 0.2s ease;
        }
        .demo-item:hover {
            background: #ffffff;
            border-color: var(--egerton-gold);
            transform: translateY(-1px);
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08);
        }
        .demo-icon {
            font-size: 0.9rem;
            color: var(--egerton-green);
            width: 24px;
            text-align: center;
        }
        .demo-info { line-height: 1.2; text-align: left; }
        .demo-info span { display: block; font-weight: 700; font-size: 0.65rem; color: #1e293b; }
        .demo-info small { font-size: 0.55rem; color: #4b5563; font-family: monospace; letter-spacing: 0.2px; }
        .demo-hint {
            margin-top: 8px;
            font-size: 0.55rem;
            color: #2c5a2a;
            text-align: center;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 4px;
            background: rgba(255, 255, 255, 0.6);
            border-radius: 30px;
            padding: 4px 10px;
        }
        .alert-success-custom {
            background-color: rgba(212, 237, 218, 0.98);
            border: 1px solid #c3e6cb;
            color: #155724;
            border-radius: 10px;
            padding: 6px 10px;
            font-size: 0.65rem;
            margin-top: 8px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
    </style>
</head>
<body>
    <!-- Slideshow Background -->
    <div class="slideshow-container" id="slideshowContainer"></div>
    <div class="background-overlay"></div>

    <!-- Corporate Green Bottom Bar with Scrolling Text -->
    <div class="corporate-green-bar">
        <div class="scrolling-text">
            <div class="scrolling-content">
                <span><strong>MISSION:</strong> To revolutionize campus facility management through innovative, sustainable, and student-centric solutions that enhance learning environments.</span>
                <span class="separator"></span>
                <span><strong>VISION:</strong> To be Africa's leading smart campus, setting the standard for excellence in facility management and operational efficiency.</span>
                <span class="separator"></span>
                <span><strong>MOTTO:</strong> "Excellence Through Innovation — Transforming Spaces, Empowering Minds."</span>
                <span class="separator"></span>
                <span><strong>CORE VALUE:</strong> Integrity, Sustainability, Innovation, Excellence, and Community First.</span>
                <span class="separator"></span>
                <!-- Duplicate for seamless scroll -->
                <span><strong>MISSION:</strong> To revolutionize campus facility management through innovative, sustainable, and student-centric solutions that enhance learning environments.</span>
                <span class="separator"></span>
                <span><strong>VISION:</strong> To be Africa's leading smart campus, setting the standard for excellence in facility management and operational efficiency.</span>
                <span class="separator"></span>
                <span><strong>MOTTO:</strong> "Excellence Through Innovation — Transforming Spaces, Empowering Minds."</span>
                <span class="separator"></span>
                <span><strong>CORE VALUE:</strong> Integrity, Sustainability, Innovation, Excellence, and Community First.</span>
            </div>
        </div>
    </div>

    <!-- Slideshow Indicator Dots -->
    <div class="slideshow-dots" id="slideshowDots"></div>

    <div class="auth-wrapper">
        <div class="main-container">
            <div class="header-section">
                <h1>SmartCampus</h1>
                <p>Facility Management — Egerton University</p>
            </div>

            <!-- Auth Tabs -->
            <div class="auth-tabs">
                <button class="tab-btn <%= "signin".equals(activeTab) ? "active" : "" %>" onclick="switchTab('signin')">Sign In</button>
                <button class="tab-btn <%= "signup".equals(activeTab) ? "active" : "" %>" onclick="switchTab('signup')">Create Account</button>
            </div>

            <!-- Sign In Section (auth-card + demo section) -->
            <div id="signinSection" style="width:100%;<%= "signup".equals(activeTab) ? "display:none;" : "" %>">
                <div class="auth-card">
                    <h2>Welcome back</h2>
                    <form id="loginForm" action="<%= ctx %>/login" method="post">
                        <div class="form-group">
                            <label for="loginEmail" class="form-label"><i class="bi bi-envelope-fill"></i> Email Address <span class="required">*</span></label>
                            <input type="email" name="email" class="form-control" id="loginEmail"
                                   placeholder="name.role@egerton.ac.ke"
                                   value="<%= emailValue != null ? emailValue : "" %>"
                                   autocomplete="off" required>
                        </div>
                        <div class="form-group">
                            <label for="loginPassword" class="form-label"><i class="bi bi-lock-fill"></i> Password <span class="required">*</span></label>
                            <input type="password" name="password" class="form-control" id="loginPassword"
                                   placeholder="Enter your password" autocomplete="off" required>
                        </div>
                        <button type="submit" class="btn-auth" id="signinBtn">
                            <i class="bi bi-box-arrow-in-right"></i> Sign In
                        </button>
                    </form>
                    <% if (errorMessage != null) { %>
                    <div class="alert-custom" style="display:flex;">
                        <i class="bi bi-exclamation-triangle-fill"></i>
                        <span><%= errorMessage %></span>
                    </div>
                    <% } %>
                    <% if (registerSuccess != null) { %>
                    <div class="alert-success-custom">
                        <i class="bi bi-check-circle-fill"></i>
                        <span><%= registerSuccess %></span>
                    </div>
                    <% } %>
                </div>
            </div>
                
                  <!-- Sign Up Card -->
            <div id="signupForm" class="auth-card" style="<%= "signin".equals(activeTab) ? "display:none;" : "" %>">
                <h2>Create Account</h2>
                <form id="registerForm" action="<%= ctx %>/register" method="post">
                    <div class="form-group">
                        <label for="regFullName" class="form-label"><i class="bi bi-person-fill"></i> Full Name <span class="required">*</span></label>
                        <input type="text" name="name" class="form-control" id="regFullName"
                               placeholder="e.g., Dr. John Doe"
                               value="<%= regName %>" required autoComplete="username">
                        <div id="nameError" class="error-message text-danger" style="display:none;"></div>
                    </div>
                    <div class="form-group">
                        <label for="regEmail" class="form-label"><i class="bi bi-envelope-fill"></i> Email Address <span class="required">*</span></label>
                        <input type="email" name="email" class="form-control" id="regEmail"
                               placeholder="name.role@egerton.ac.ke"
                               value="<%= regEmail %>" required autoComplete="email">
                        <div id="emailError" class="error-message text-danger" style="display:none;"></div>
                    </div>
                    <div class="form-group">
                        <label for="regPhone" class="form-label"><i class="bi bi-telephone-fill"></i> Phone Number <span class="required">*</span></label>
                        <input type="tel" name="phone" class="form-control" id="regPhone"
                               placeholder="0712345678"
                               value="<%= regPhone %>" required autoComplete="phone">
                        <div id="phoneError" class="error-message text-danger" style="display:none;"></div>
                    </div>
                    <div class="form-group">
                        <label for="regGender" class="form-label"><i class="bi bi-venus-mars"></i> Gender <span class="required">*</span></label>
                        <select name="gender" class="form-select" id="regGender" required>
                            <option value="">Select Gender</option>
                            <option value="Male" <%= "Male".equals(regGender) ? "selected" : "" %>>Male</option>
                            <option value="Female" <%= "Female".equals(regGender) ? "selected" : "" %>>Female</option>
                            <option value="Other" <%= "Other".equals(regGender) ? "selected" : "" %>>Other</option>
                        </select>
                        <div id="genderError" class="error-message text-danger" style="display:none;"></div>
                    </div>
                    <div class="form-group">
                        <label for="regRole" class="form-label"><i class="bi bi-briefcase-fill"></i> Role <span class="required">*</span></label>
                        <select name="role" class="form-select" id="regRole" required onchange="updateRoleFields()">
                            <option value="lecturer" <%= "lecturer".equals(regRole) ? "selected" : "" %>>Lecturer</option>
                            <option value="janitor" <%= "janitor".equals(regRole) ? "selected" : "" %>>Janitor</option>
                            <option value="supervisor" <%= "supervisor".equals(regRole) ? "selected" : "" %>>Supervisor</option>
                            <option value="admin" <%= "admin".equals(regRole) ? "selected" : "" %>>Administrator</option>
                        </select>
                    </div>
                    <div id="roleSpecificFields" class="role-fields-section"></div>
                    <div class="form-group">
                        <label for="regPassword" class="form-label"><i class="bi bi-lock-fill"></i> Password <span class="required">*</span></label>
                        <input type="password" name="password" class="form-control" id="regPassword"
                               placeholder="Create a strong password" required autoComplete="new-password" onkeyup="checkPasswordStrength()">
                        <div class="password-strength">
                            <div class="strength-bar" id="strengthBar" style="width:0%;background:#ddd;"></div>
                            <small id="strengthText" class="text-muted"></small>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="regConfirmPassword" class="form-label"><i class="bi bi-shield-lock-fill"></i> Confirm Password <span class="required">*</span></label>
                        <input type="password" name="confirmPassword" class="form-control" id="regConfirmPassword"
                               placeholder="Confirm your password" required autoComplete="new-password">
                        <div id="confirmPasswordError" class="error-message text-danger" style="display:none;"></div>
                    </div>
                    <div class="terms-check">
                        <input type="checkbox" id="termsCheck" required>
                        <label for="termsCheck">I agree to the <a href="#" onclick="return false;">Terms of Use</a> and <a href="#" onclick="return false;">Privacy Policy</a></label>
                    </div>
                    <button type="submit" class="btn-auth">
                        <i class="bi bi-person-plus-fill"></i> Create Account
                    </button>
                </form>
                <% if (registerError != null) { %>
                <div class="alert-custom" style="display:flex;margin-top:10px;">
                    <i class="bi bi-exclamation-triangle-fill"></i>
                    <span><%= registerError %></span>
                </div>
                <% } %>
            </div>
           </div>
        </div>

      

        <div class="footer-note">
            <i class="bi bi-c-circle"></i> SmartCampus | Egerton University — Excellence Through Innovation
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // ============= SLIDESHOW =============
        
       const backgroundImages = [
    "<%= ctx %>/Images/Banner28.jpg",
    "<%= ctx %>/Images/egerton_viewhd.jpg",
//    "<%= ctx %>/Images/ss7.jpeg",
    "<%= ctx %>/Images/1.jpg"
];

const slideshowContainer = document.getElementById("slideshowContainer");
let currentIndex = 0;
let slides = [];

function createSlides() {
    backgroundImages.forEach((img, index) => {
        const slide = document.createElement("div");
        slide.className = "slide";
        slide.style.backgroundImage = "url('" + img + "')";

        if (index === 0) {
            slide.classList.add("active"); // VERY IMPORTANT
        }

        slideshowContainer.appendChild(slide);
        slides.push(slide);
    });
}

function showNextSlide() {
    slides[currentIndex].classList.remove("active");
    currentIndex = (currentIndex + 1) % slides.length;
    slides[currentIndex].classList.add("active");
}

createSlides();
setInterval(showNextSlide, 5000);

        // ============= DEMO ACCOUNT AUTO-FILL =============
        function fillDemo(email, password) {
            document.getElementById('loginEmail').value = email;
            document.getElementById('loginPassword').value = password;
            const btn = document.getElementById('signinBtn');
            if (btn) {
                btn.disabled = true;
                btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span> Signing in\u2026';
            }
            document.getElementById('loginForm').submit();
        }

        // ============= TAB SWITCHING =============
        function switchTab(tab) {
            const signinSection = document.getElementById('signinSection');
            const signupForm = document.getElementById('signupForm');
            const tabs = document.querySelectorAll('.tab-btn');
            if (tab === 'signin') {
                signinSection.style.display = 'block';
                signupForm.style.display = 'none';
                tabs[0].classList.add('active');
                tabs[1].classList.remove('active');
            } else {
                signinSection.style.display = 'none';
                signupForm.style.display = 'block';
                tabs[0].classList.remove('active');
                tabs[1].classList.add('active');
                updateRoleFields();
            }
        }

        // ============= TOAST =============
        function showToast(message, type) {
            if (!type) type = 'success';
            const toastDiv = document.createElement('div');
            toastDiv.className = 'custom-toast';
            toastDiv.style.backgroundColor = type === 'success' ? '#00A651' : (type === 'error' ? '#dc3545' : '#17a2b8');
            toastDiv.style.color = 'white';
            let icon = type === 'success' ? '<i class="bi bi-check-circle-fill"></i>'
                      : type === 'error'   ? '<i class="bi bi-exclamation-triangle-fill"></i>'
                      : '<i class="bi bi-info-circle-fill"></i>';
            toastDiv.innerHTML = icon + '<span>' + message + '</span>';
            document.body.appendChild(toastDiv);
            setTimeout(function() {
                toastDiv.style.animation = 'slideOut 0.3s ease';
                setTimeout(function() { toastDiv.remove(); }, 300);
            }, 3000);
            toastDiv.onclick = function() { toastDiv.style.animation = 'slideOut 0.3s ease'; setTimeout(function() { toastDiv.remove(); }, 300); };
        }

        // ============= VALIDATION FUNCTIONS =============
        function validateFullName(name) {
            const nameRegex = /^[A-Za-z\s\.]+$/;
            if (!name.trim()) return { valid: false, message: "Full name is required" };
            if (name.trim().length < 3) return { valid: false, message: "Name must be at least 3 characters" };
            if (!nameRegex.test(name)) return { valid: false, message: "Name should only contain letters, spaces, and periods" };
            return { valid: true };
        }
        function validateEmail(email) {
            const emailRegex = /^[a-zA-Z0-9._\-]+\.(admin|lecturer|janitor|supervisor)@egerton\.ac\.ke$/i;
            if (!email.trim()) return { valid: false, message: "Email address is required" };
            if (!emailRegex.test(email)) return { valid: false, message: "Email must be in the format name.role@egerton.ac.ke (e.g. john.lecturer@egerton.ac.ke)" };
            return { valid: true };
        }
        function validatePhone(phone) {
            const phoneRegex = /^[+]?[\d\s()\-]{7,15}$/;
            if (!phone.trim()) return { valid: false, message: "Phone number is required" };
            if (!phoneRegex.test(phone)) return { valid: false, message: "Please enter a valid phone number" };
            return { valid: true };
        }
        function validateFloor(floorValue) {
            const validFloors = ["basement", "groundfloor", "first", "second", "third"];
            const floorLower = floorValue.toString().toLowerCase().trim();
            if (validFloors.includes(floorLower)) return { valid: true, value: floorLower };
            if (!isNaN(floorValue) && parseInt(floorValue) >= 0 && parseInt(floorValue) <= 3) {
                const floorMap = { 0: "groundfloor", 1: "first", 2: "second", 3: "third" };
                return { valid: true, value: floorMap[parseInt(floorValue)] };
            }
            return { valid: false, message: "Floor must be: basement, groundfloor, first, second, or third" };
        }
        function validateStaffId(staffId, prefix) {
            const staffIdRegex = new RegExp('^' + prefix + '-\\d{4}-\\d{3}$', 'i');
            if (!staffId || !staffId.trim()) return { valid: false, message: "Staff ID is required" };
            if (!staffIdRegex.test(staffId.toUpperCase())) {
                return { valid: false, message: 'Staff ID must follow format: ' + prefix + '-YYYY-ZZZ (e.g., ' + prefix + '-2024-001)' };
            }
            return { valid: true };
        }

        // ============= ROLE-SPECIFIC FIELDS =============
        function updateRoleFields() {
            const role = document.getElementById('regRole').value;
            const container = document.getElementById('roleSpecificFields');
            let html = '<div class="role-fields-title"><i class="bi bi-briefcase"></i> Role-Specific Information</div>';
            if (role === 'lecturer') {
                html += '<div class="form-group">'
                    + '<label for="lecturerOffice" class="form-label"><i class="bi bi-door-closed"></i> Office Number <span class="required">*</span></label>'
                    + '<input type="text" name="officeNumber" class="form-control" id="lecturerOffice" placeholder="e.g., A101, B202">'
                    + '<div id="officeError" class="error-message text-danger" style="display:none;"></div>'
                    + '</div>'
                    + '<div class="form-group">'
                    + '<label for="lecturerWing" class="form-label"><i class="bi bi-diagram-3"></i> Wing <span class="required">*</span></label>'
                    + '<select name="wing" class="form-select" id="lecturerWing">'
                    + '<option value="">Select Wing</option>'
                    + '<option value="A">A Wing</option>'
                    + '<option value="B">B Wing</option>'
                    + '<option value="C">C Wing</option>'
                    + '<option value="D">D Wing</option>'
                    + '</select>'
                    + '<div id="wingError" class="error-message text-danger" style="display:none;"></div>'
                    + '</div>'
                    + '<div class="form-group">'
                    + '<label for="lecturerFloor" class="form-label"><i class="bi bi-stack"></i> Floor <span class="required">*</span></label>'
                    + '<input type="text" name="floor" class="form-control" id="lecturerFloor" placeholder="basement, groundfloor, first, second, third">'
                    + '<div id="floorError" class="error-message text-danger" style="display:none;"></div>'
                    + '</div>';
            } else if (role === 'janitor') {
                html += '<div class="form-group">'
                    + '<label for="janitorStaffId" class="form-label"><i class="bi bi-upc-scan"></i> Staff ID <span class="required">*</span></label>'
                    + '<input type="text" name="staffId" class="form-control" id="janitorStaffId" placeholder="e.g., JAN-2024-001">'
                    + '<div id="staffIdError" class="error-message text-danger" style="display:none;"></div>'
                    + '</div>'
                    + '<div class="form-group">'
                    + '<label for="janitorWing" class="form-label"><i class="bi bi-tools"></i> Assigned Wing</label>'
                    + '<select name="wing" class="form-select" id="janitorWing">'
                    + '<option value="">Select Wing (Optional)</option>'
                    + '<option value="A">A Wing</option>'
                    + '<option value="B">B Wing</option>'
                    + '<option value="C">C Wing</option>'
                    + '<option value="D">D Wing</option>'
                    + '<option value="All">All Wings</option>'
                    + '</select>'
                    + '</div>';
            } else if (role === 'supervisor') {
                html += '<div class="form-group">'
                    + '<label for="supervisorStaffId" class="form-label"><i class="bi bi-upc-scan"></i> Staff ID <span class="required">*</span></label>'
                    + '<input type="text" name="staffId" class="form-control" id="supervisorStaffId" placeholder="e.g., SUP-2024-001">'
                    + '<div id="supStaffIdError" class="error-message text-danger" style="display:none;"></div>'
                    + '</div>'
                    + '<div class="form-group">'
                    + '<label for="supervisorWing" class="form-label"><i class="bi bi-diagram-3"></i> Supervisory Wing</label>'
                    + '<select name="wing" class="form-select" id="supervisorWing">'
                    + '<option value="">Select Wing (Optional)</option>'
                    + '<option value="A">A Wing</option>'
                    + '<option value="B">B Wing</option>'
                    + '<option value="C">C Wing</option>'
                    + '<option value="D">D Wing</option>'
                    + '<option value="All">All Wings</option>'
                    + '</select>'
                    + '</div>';
            } else if (role === 'admin') {
                html += '<div class="form-group">'
                    + '<label for="adminStaffId" class="form-label"><i class="bi bi-upc-scan"></i> Staff ID <span class="required">*</span></label>'
                    + '<input type="text" name="staffId" class="form-control" id="adminStaffId" placeholder="e.g., ADM-2024-001">'
                    + '<div id="adminStaffIdError" class="error-message text-danger" style="display:none;"></div>'
                    + '</div>'
                    + '<div class="form-group">'
                    + '<label for="adminDept" class="form-label"><i class="bi bi-building"></i> Department</label>'
                    + '<input type="text" name="department" class="form-control" id="adminDept" placeholder="e.g., ICT Department">'
                    + '</div>';
            }
            container.innerHTML = html;
        }

        // ============= PASSWORD STRENGTH =============
        function checkPasswordStrength() {
            const password = document.getElementById('regPassword').value;
            const strengthBar = document.getElementById('strengthBar');
            const strengthText = document.getElementById('strengthText');
            let strength = 0;
            if (password.length >= 6) strength++;
            if (password.length >= 10) strength++;
            if (/[A-Z]/.test(password)) strength++;
            if (/[0-9]/.test(password)) strength++;
            if (/[^A-Za-z0-9]/.test(password)) strength++;
            const levels = [
                { pct: '20%', color: '#dc3545', label: 'Weak' },
                { pct: '20%', color: '#dc3545', label: 'Weak' },
                { pct: '50%', color: '#ffc107', label: 'Medium' },
                { pct: '50%', color: '#ffc107', label: 'Medium' },
                { pct: '80%', color: '#28a745', label: 'Strong' },
                { pct: '100%', color: '#00A651', label: 'Very Strong' }
            ];
            const lvl = levels[strength] || levels[0];
            strengthBar.style.width = lvl.pct;
            strengthBar.style.background = lvl.color;
            strengthText.textContent = lvl.label;
            strengthText.style.color = lvl.color;
            const confirmInput = document.getElementById('regConfirmPassword');
            if (confirmInput && confirmInput.value) confirmInput.dispatchEvent(new Event('input'));
        }

        // ============= REAL-TIME VALIDATION =============
        document.addEventListener('DOMContentLoaded', function() {
            document.getElementById('regFullName').addEventListener('input', function() {
                const result = validateFullName(this.value);
                const errorDiv = document.getElementById('nameError');
                if (!result.valid) { errorDiv.style.display = 'block'; errorDiv.textContent = result.message; this.classList.add('is-invalid'); this.classList.remove('is-valid'); }
                else { errorDiv.style.display = 'none'; this.classList.remove('is-invalid'); this.classList.add('is-valid'); }
            });
            document.getElementById('regEmail').addEventListener('input', function() {
                const result = validateEmail(this.value);
                const errorDiv = document.getElementById('emailError');
                if (!result.valid) { errorDiv.style.display = 'block'; errorDiv.textContent = result.message; this.classList.add('is-invalid'); this.classList.remove('is-valid'); }
                else { errorDiv.style.display = 'none'; this.classList.remove('is-invalid'); this.classList.add('is-valid'); }
            });
            document.getElementById('regPhone').addEventListener('input', function() {
                const result = validatePhone(this.value);
                const errorDiv = document.getElementById('phoneError');
                if (!result.valid) { errorDiv.style.display = 'block'; errorDiv.textContent = result.message; this.classList.add('is-invalid'); this.classList.remove('is-valid'); }
                else { errorDiv.style.display = 'none'; this.classList.remove('is-invalid'); this.classList.add('is-valid'); }
            });
            document.getElementById('regGender').addEventListener('change', function() {
                const errorDiv = document.getElementById('genderError');
                if (!this.value) { errorDiv.style.display = 'block'; errorDiv.textContent = 'Please select your gender'; this.classList.add('is-invalid'); }
                else { errorDiv.style.display = 'none'; this.classList.remove('is-invalid'); this.classList.add('is-valid'); }
            });
            document.getElementById('regConfirmPassword').addEventListener('input', function() {
                const password = document.getElementById('regPassword').value;
                const errorDiv = document.getElementById('confirmPasswordError');
                if (this.value !== password) { errorDiv.style.display = 'block'; errorDiv.textContent = 'Passwords do not match'; this.classList.add('is-invalid'); this.classList.remove('is-valid'); }
                else if (this.value) { errorDiv.style.display = 'none'; this.classList.remove('is-invalid'); this.classList.add('is-valid'); }
                else { errorDiv.style.display = 'none'; this.classList.remove('is-invalid'); this.classList.remove('is-valid'); }
            });

            // ============= REGISTER FORM CLIENT-SIDE VALIDATION =============
            document.getElementById('registerForm').addEventListener('submit', function(e) {
                const name = document.getElementById('regFullName').value;
                const email = document.getElementById('regEmail').value;
                const phone = document.getElementById('regPhone').value;
                const gender = document.getElementById('regGender').value;
                const password = document.getElementById('regPassword').value;
                const confirmPassword = document.getElementById('regConfirmPassword').value;
                const terms = document.getElementById('termsCheck').checked;

                let valid = true;

                const nameResult = validateFullName(name);
                if (!nameResult.valid) {
                    const d = document.getElementById('nameError'); d.style.display = 'block'; d.textContent = nameResult.message;
                    document.getElementById('regFullName').classList.add('is-invalid'); valid = false;
                }
                const emailResult = validateEmail(email);
                if (!emailResult.valid) {
                    const d = document.getElementById('emailError'); d.style.display = 'block'; d.textContent = emailResult.message;
                    document.getElementById('regEmail').classList.add('is-invalid'); valid = false;
                }
                const phoneResult = validatePhone(phone);
                if (!phoneResult.valid) {
                    const d = document.getElementById('phoneError'); d.style.display = 'block'; d.textContent = phoneResult.message;
                    document.getElementById('regPhone').classList.add('is-invalid'); valid = false;
                }
                if (!gender) {
                    const d = document.getElementById('genderError'); d.style.display = 'block'; d.textContent = 'Please select your gender';
                    document.getElementById('regGender').classList.add('is-invalid'); valid = false;
                }
                if (password.length < 6) {
                    showToast('Password must be at least 6 characters', 'error'); valid = false;
                }
                if (password !== confirmPassword) {
                    const d = document.getElementById('confirmPasswordError'); d.style.display = 'block'; d.textContent = 'Passwords do not match';
                    document.getElementById('regConfirmPassword').classList.add('is-invalid'); valid = false;
                }
                if (!terms) {
                    showToast('Please agree to the Terms of Use', 'error'); valid = false;
                }
                if (!valid) { e.preventDefault(); }
            });
        });

        // Initialize
        initSlideshow();
        updateRoleFields();
    </script>
</body>
</html>
