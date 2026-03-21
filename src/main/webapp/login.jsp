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
    String errorMessage = (String) request.getAttribute("error");
    String emailValue   = (String) request.getAttribute("emailValue");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SmartCampus | Egerton University - Facility Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <style>
        :root {
            --egerton-green: #00A651;
            --egerton-green-dark: #008a43;
            --egerton-gold: #D2AC67;
            --card-bg: rgba(255,255,255,0.96);
            --input-bg: rgba(248,249,250,0.95);
            --text-dark: #1F2A3A;
        }
        * { margin:0; padding:0; box-sizing:border-box; }
        body { min-height:100vh; display:flex; align-items:center; justify-content:center;
               font-family:'Inter',sans-serif; padding:12px; position:relative; }
        .bg-wrapper { position:fixed; inset:0; z-index:0; }
        .bg-img { width:100%; height:100%; object-fit:cover; filter:brightness(0.6); }
        .bg-overlay { position:fixed; inset:0;
                      background:linear-gradient(135deg,rgba(0,30,10,.5) 0%,rgba(0,90,40,.4) 100%);
                      z-index:1; }
        .main-container { width:100%; max-width:420px; position:relative; z-index:2; }
        .header-section { text-align:center; margin-bottom:10px; }
        .header-section h1 { font-family:'Playfair Display',serif; font-size:1.6rem; font-weight:800;
                              color:white; text-shadow:0 2px 8px rgba(0,0,0,.3); }
        .header-section p { font-size:.65rem; color:#fff9ef; background:rgba(0,0,0,.4);
                             display:inline-block; padding:2px 12px; border-radius:30px; }
        .login-card { background:var(--card-bg); border-radius:20px; padding:20px 24px;
                      box-shadow:0 8px 20px -6px rgba(0,0,0,.15); margin-bottom:12px; }
        .login-card h2 { font-family:'Playfair Display',serif; font-size:1.2rem; font-weight:700;
                          text-align:center; margin-bottom:14px;
                          background:linear-gradient(135deg,#1e4620,#00A651);
                          background-clip:text; -webkit-background-clip:text; color:transparent; }
        .form-group { margin-bottom:12px; }
        .form-label { font-weight:600; color:var(--text-dark); font-size:.72rem;
                      margin-bottom:4px; display:flex; align-items:center; gap:5px; }
        .form-label i { color:var(--egerton-green); }
        .form-control { background:var(--input-bg); border:1.5px solid #e9ecef; padding:7px 12px;
                        border-radius:12px; font-size:.82rem; width:100%; height:36px; }
        .form-control:focus { background:#fff; border-color:var(--egerton-green);
                               box-shadow:0 0 0 3px rgba(0,166,81,.12); outline:none; }
        .btn-signin { background:linear-gradient(105deg,var(--egerton-green-dark),var(--egerton-green));
                      color:white; width:100%; padding:8px; border-radius:40px; border:none;
                      font-weight:700; font-size:.82rem; margin-top:8px; cursor:pointer; }
        .btn-signin:hover { background:linear-gradient(105deg,#006622,#008f45); }
        .alert-error { background:rgba(248,215,218,.98); border:1px solid #f5c6cb; color:#721c24;
                       border-radius:10px; padding:8px 12px; font-size:.72rem; margin-top:10px; }
        .demo-card { background:rgba(255,255,255,.95); border-radius:18px; padding:10px 16px 12px;
                     box-shadow:0 4px 12px rgba(0,0,0,.1); border:1px solid rgba(210,172,103,.4); }
        .demo-title { color:#007624; font-size:.65rem; font-weight:700; margin-bottom:8px;
                      text-transform:uppercase; letter-spacing:1px;
                      display:flex; align-items:center; gap:5px; justify-content:center; }
        .demo-grid { display:grid; grid-template-columns:repeat(2,1fr); gap:6px; }
        .demo-item { background:#f1f5f9; padding:6px 8px; border-radius:12px;
                     display:flex; align-items:center; gap:8px; cursor:pointer;
                     border:1px solid transparent; transition:all .2s; }
        .demo-item:hover { background:#fff; border-color:var(--egerton-gold);
                           transform:translateY(-1px); }
        .demo-icon { font-size:.9rem; color:var(--egerton-green); width:24px; text-align:center; }
        .demo-info span { display:block; font-weight:700; font-size:.65rem; }
        .demo-info small { font-size:.55rem; color:#4b5563; font-family:monospace; }
        .footer-note { margin-top:8px; font-size:.55rem; color:rgba(255,255,240,.9);
                       text-align:center; }
    </style>
</head>
<body>
    <div class="bg-wrapper">
        <img class="bg-img"
             src="https://fos.egerton.ac.ke/images/faculty_of_sciences/Banner28.jpg"
             alt="Egerton University"
             onerror="this.src='https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=1600&h=900&fit=crop'">
    </div>
    <div class="bg-overlay"></div>

    <div class="main-container">
        <div class="header-section">
            <h1>SmartCampus</h1>
            <p>Facility Management — Egerton University</p>
        </div>

        <div class="login-card">
            <h2>Welcome back</h2>
            <form action="<%= request.getContextPath() %>/login" method="post" id="loginForm">
                <div class="form-group">
                    <label class="form-label"><i class="bi bi-envelope-fill"></i> Email address</label>
                    <input type="email" name="email" class="form-control" id="emailInput"
                           placeholder="your@egerton.ac.ke"
                           value="<%= emailValue != null ? emailValue : "admin@egerton.ac.ke" %>"
                           required>
                </div>
                <div class="form-group">
                    <label class="form-label"><i class="bi bi-lock-fill"></i> Password</label>
                    <input type="password" name="password" class="form-control" id="passwordInput"
                           placeholder="············" value="admin123" required>
                </div>
                <button type="submit" class="btn-signin">
                    <i class="bi bi-box-arrow-in-right"></i> Sign In
                </button>
            </form>
            <% if (errorMessage != null) { %>
            <div class="alert-error">
                <i class="bi bi-exclamation-triangle-fill"></i> <%= errorMessage %>
            </div>
            <% } %>
        </div>

        <div class="demo-card">
            <div class="demo-title"><i class="bi bi-stars"></i> QUICK DEMO ACCESS <i class="bi bi-stars"></i></div>
            <div class="demo-grid">
                <div class="demo-item" onclick="fillDemo('admin@egerton.ac.ke','admin123')">
                    <div class="demo-icon"><i class="bi bi-shield-lock-fill"></i></div>
                    <div class="demo-info"><span>Administrator</span><small>admin@egerton.ac.ke</small></div>
                </div>
                <div class="demo-item" onclick="fillDemo('swanjiku@egerton.ac.ke','lecturer123')">
                    <div class="demo-icon"><i class="bi bi-mortarboard-fill"></i></div>
                    <div class="demo-info"><span>Lecturer</span><small>swanjiku@egerton.ac.ke</small></div>
                </div>
                <div class="demo-item" onclick="fillDemo('jkamau@egerton.ac.ke','janitor123')">
                    <div class="demo-icon"><i class="bi bi-tools"></i></div>
                    <div class="demo-info"><span>Janitor</span><small>jkamau@egerton.ac.ke</small></div>
                </div>
                <div class="demo-item" onclick="fillDemo('mchebet@egerton.ac.ke','super123')">
                    <div class="demo-icon"><i class="bi bi-clipboard2-check-fill"></i></div>
                    <div class="demo-info"><span>Supervisor</span><small>mchebet@egerton.ac.ke</small></div>
                </div>
            </div>
        </div>
        <div class="footer-note"><i class="bi bi-c-circle"></i> SmartCampus | Egerton University</div>
    </div>

    <script>
        function fillDemo(email, password) {
            document.getElementById('emailInput').value = email;
            document.getElementById('passwordInput').value = password;
        }
    </script>
</body>
</html>
