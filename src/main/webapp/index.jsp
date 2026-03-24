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
            --demo-bg: rgba(241, 245, 249, 0.98);
            --shadow-sm: 0 8px 20px -6px rgba(0, 0, 0, 0.15);
        }

        body {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Inter', sans-serif;
            padding: 12px;
            margin: 0;
            position: relative;
        }

        /* Slideshow Container */
        .slideshow-container {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 0;
            overflow: hidden;
        }

        .slide {
            position: absolute;
            top: 0;
            left: 0;
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

        /* Dark Overlay for Better Text Readability */
        .background-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(135deg, rgba(0, 30, 10, 0.5) 0%, rgba(0, 90, 40, 0.4) 100%);
            z-index: 1;
        }

        /* Solid Corporate Green Bottom Section */
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

        /* Scrolling Text Container */
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
            0% {
                transform: translateX(0);
            }
            100% {
                transform: translateX(-50%);
            }
        }

        /* Content Container */
        .main-container {
            width: 100%;
            max-width: 420px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            position: relative;
            z-index: 3;
            margin-bottom: 60px;
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
            line-height: 1.2;
        }

        .header-section p {
            font-weight: 500;
            font-size: 0.65rem;
            opacity: 0.95;
            color: #fff9ef;
            letter-spacing: 0.3px;
            background: rgba(0, 0, 0, 0.4);
            display: inline-block;
            padding: 2px 10px;
            border-radius: 30px;
        }

        .login-card {
            background: var(--card-bg);
            border-radius: 20px;
            padding: 16px 24px 18px;
            box-shadow: var(--shadow-sm);
            margin-bottom: 12px;
            width: 100%;
            border: 1px solid rgba(255, 255, 255, 0.3);
        }

        .login-card h2 {
            font-family: 'Playfair Display', serif;
            font-size: 1.2rem;
            font-weight: 700;
            text-align: center;
            margin-bottom: 12px;
            background: linear-gradient(135deg, #1e4620, #00A651);
            background-clip: text;
            -webkit-background-clip: text;
            color: transparent;
        }

        .form-group {
            text-align: left;
            margin-bottom: 10px;
        }

        .form-label {
            font-weight: 600;
            color: var(--text-dark);
            font-size: 0.7rem;
            margin-bottom: 3px;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .form-label i {
            color: var(--egerton-green);
            font-size: 0.75rem;
        }

        .form-control {
            background-color: var(--input-bg);
            border: 1.5px solid #e9ecef;
            padding: 6px 12px;
            border-radius: 12px;
            font-size: 0.8rem;
            font-weight: 500;
            color: #1f2a3a;
            transition: all 0.2s;
            width: 100%;
            height: 34px;
        }

        .form-control:focus {
            background-color: #ffffff;
            border-color: var(--egerton-green);
            box-shadow: 0 0 0 3px rgba(0, 166, 81, 0.12);
            outline: none;
        }

        .btn-signin {
            background: linear-gradient(105deg, var(--egerton-green-dark), var(--egerton-green));
            color: white;
            width: 100%;
            padding: 6px;
            border-radius: 40px;
            border: none;
            font-weight: 700;
            font-size: 0.8rem;
            transition: all 0.2s;
            margin-top: 6px;
            box-shadow: 0 2px 6px rgba(0, 118, 36, 0.2);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            cursor: pointer;
        }

        .btn-signin:hover {
            background: linear-gradient(105deg, #006622, #008f45);
            transform: translateY(-1px);
            box-shadow: 0 4px 10px rgba(0, 80, 30, 0.25);
        }

        .btn-signin:active {
            transform: translateY(1px);
        }

        .demo-card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 18px;
            padding: 10px 16px 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            width: 100%;
            border: 1px solid rgba(210, 172, 103, 0.4);
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

        .demo-title i {
            font-size: 0.75rem;
        }

        .demo-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 6px;
        }

        .demo-item {
            background: var(--demo-bg);
            padding: 5px 8px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
            color: inherit;
            transition: all 0.2s ease;
            border: 1px solid transparent;
            cursor: pointer;
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

        .demo-info {
            line-height: 1.2;
            text-align: left;
        }

        .demo-info span {
            display: block;
            font-weight: 700;
            font-size: 0.65rem;
            color: #1e293b;
        }

        .demo-info small {
            font-size: 0.55rem;
            color: #4b5563;
            font-family: monospace;
            letter-spacing: 0.2px;
            word-break: break-all;
        }

        .footer-note {
            margin-top: 8px;
            font-size: 0.55rem;
            color: rgba(255, 255, 240, 0.9);
            text-align: center;
            text-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
        }

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
            width: fit-content;
            margin-left: auto;
            margin-right: auto;
        }

        .alert-danger-custom {
            background-color: rgba(248, 215, 218, 0.98);
            border: 1px solid #f5c6cb;
            color: #721c24;
            border-radius: 10px;
            padding: 6px 10px;
            font-size: 0.65rem;
            margin-top: 8px;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        /* Slideshow Indicator Dots */
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

        @media (max-width: 768px) {
            .main-container {
                max-width: 100%;
                margin-bottom: 60px;
            }
            .login-card {
                padding: 14px 18px 16px;
            }
            .demo-grid {
                grid-template-columns: 1fr;
                gap: 5px;
            }
            .header-section h1 {
                font-size: 1.3rem;
            }
            .form-control {
                height: 32px;
                padding: 5px 10px;
            }
            .slideshow-dots {
                bottom: 60px;
            }
            .corporate-green-bar {
                height: 45px;
            }
            .scrolling-content {
                font-size: 0.9rem;
                animation: scroll-left 40s linear infinite;
            }
            .scrolling-content strong {
                font-size: 1rem;
            }
            .separator {
                height: 20px;
                margin: 0 15px;
            }
            .scrolling-content span {
                margin: 0 25px;
            }
        }

        @keyframes slideIn {
            from {
                transform: translateX(100%);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }

        @keyframes slideOut {
            from {
                transform: translateX(0);
                opacity: 1;
            }
            to {
                transform: translateX(100%);
                opacity: 0;
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
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
            animation: slideIn 0.3s ease;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 6px;
        }
    </style>
</head>
<body>
    <!-- Slideshow Background -->
    <div class="slideshow-container" id="slideshowContainer">
        <!-- Slides will be dynamically added via JavaScript -->
    </div>
    <div class="background-overlay"></div>

    <!-- Solid Corporate Green Bottom Bar with Scrolling Text -->
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
                <!-- Duplicate content for seamless infinite scroll -->
                <span class="separator"></span>
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

    <div class="main-container">
        <div class="header-section">
            <h1>SmartCampus</h1>
            <p>Facility Management — Egerton University</p>
        </div>

        <div class="login-card">
            <h2>Welcome back</h2>
            <form id="loginForm" action="<%= request.getContextPath() %>/login" method="post">
                <div class="form-group">
                    <label for="emailInput" class="form-label"><i class="bi bi-envelope-fill"></i> Email address</label>
                    <input type="email" name="email" class="form-control" id="emailInput"
                           placeholder="your@egerton.ac.ke"
                           value="<%= emailValue != null ? emailValue : "" %>"
                           autocomplete="off"
                           required>
                </div>
                <div class="form-group">
                    <label for="passwordInput" class="form-label"><i class="bi bi-lock-fill"></i> Password</label>
                    <input type="password" name="password" class="form-control" id="passwordInput"
                           placeholder="············" autocomplete="off" required>
                </div>
                <button type="submit" class="btn-signin" id="signinBtn">
                    <i class="bi bi-box-arrow-in-right"></i> Sign In
                </button>
            </form>
            <% if (errorMessage != null) { %>
            <div class="alert-danger-custom">
                <i class="bi bi-exclamation-triangle-fill"></i>
                <span><%= errorMessage %></span>
            </div>
            <% } %>
        </div>

        <div class="demo-card">
            <div class="demo-title">
                <i class="bi bi-stars"></i> QUICK DEMO ACCESS <i class="bi bi-stars"></i>
            </div>
            <div class="demo-grid">
                <div class="demo-item" onclick="fillDemo('admin@egerton.ac.ke','admin123')">
                    <div class="demo-icon"><i class="bi bi-shield-lock-fill"></i></div>
                    <div class="demo-info">
                        <span>Administrator</span>
                        <small>admin@egerton.ac.ke</small>
                    </div>
                </div>
                <div class="demo-item" onclick="fillDemo('swanjiku@egerton.ac.ke','lecturer123')">
                    <div class="demo-icon"><i class="bi bi-mortarboard-fill"></i></div>
                    <div class="demo-info">
                        <span>Lecturer</span>
                        <small>swanjiku@egerton.ac.ke</small>
                    </div>
                </div>
                <div class="demo-item" onclick="fillDemo('jkamau@egerton.ac.ke','janitor123')">
                    <div class="demo-icon"><i class="bi bi-tools"></i></div>
                    <div class="demo-info">
                        <span>Janitor</span>
                        <small>jkamau@egerton.ac.ke</small>
                    </div>
                </div>
                <div class="demo-item" onclick="fillDemo('mchebet@egerton.ac.ke','super123')">
                    <div class="demo-icon"><i class="bi bi-clipboard2-check-fill"></i></div>
                    <div class="demo-info">
                        <span>Supervisor</span>
                        <small>mchebet@egerton.ac.ke</small>
                    </div>
                </div>
            </div>
            <div class="demo-hint">
                <i class="bi bi-info-circle-fill"></i> Click any account to auto-fill and sign in
            </div>
        </div>
        <div class="footer-note">
            <i class="bi bi-c-circle"></i> SmartCampus | Egerton University
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // ============= SLIDESHOW CONFIGURATION =============
        const backgroundImages = [
            "https://fos.egerton.ac.ke/images/faculty_of_sciences/Banner28.jpg",
            "https://fos.egerton.ac.ke/images/faculty_of_sciences/egerton_viewhd.jpg",
            "https://neathygiene.co.ke/images/ss7.jpeg",
            "https://neathygiene.co.ke/images/1.jpg"
        ];

        const fallbackImages = [
            "https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=1600&h=900&fit=crop",
            "https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=1600&h=900&fit=crop",
            "https://images.unsplash.com/photo-1562774053-701939374585?w=1600&h=900&fit=crop",
            "https://images.unsplash.com/photo-1541829070764-84a7f30dd3f3?w=1600&h=900&fit=crop"
        ];

        let currentSlideIndex = 0;
        let slideInterval;
        let slides = [];

        function createSlides() {
            const container = document.getElementById('slideshowContainer');
            const dotsContainer = document.getElementById('slideshowDots');
            container.innerHTML = '';
            dotsContainer.innerHTML = '';

            backgroundImages.forEach((imgUrl, index) => {
                const slide = document.createElement('div');
                slide.className = 'slide';
                if (index === 0) slide.classList.add('active');

                const img = new Image();
                img.onload = function() {
                    slide.style.backgroundImage = `url('${imgUrl}')`;
                };
                img.onerror = function() {
                    slide.style.backgroundImage = `url('${fallbackImages[index % fallbackImages.length]}')`;
                };
                img.src = imgUrl;

                container.appendChild(slide);
                slides.push(slide);

                const dot = document.createElement('div');
                dot.className = 'dot';
                if (index === 0) dot.classList.add('active');
                dot.addEventListener('click', () => goToSlide(index));
                dotsContainer.appendChild(dot);
            });
        }

        function goToSlide(index) {
            if (index === currentSlideIndex) return;
            slides[currentSlideIndex].classList.remove('active');
            document.querySelectorAll('.dot')[currentSlideIndex].classList.remove('active');
            currentSlideIndex = index;
            slides[currentSlideIndex].classList.add('active');
            document.querySelectorAll('.dot')[currentSlideIndex].classList.add('active');
        }

        function nextSlide() {
            const nextIndex = (currentSlideIndex + 1) % slides.length;
            goToSlide(nextIndex);
        }

        function startSlideshow() {
            if (slideInterval) clearInterval(slideInterval);
            slideInterval = setInterval(nextSlide, 3000);
        }

        function initSlideshow() {
            createSlides();
            startSlideshow();
        }

        // ============= DEMO ACCOUNT AUTO-FILL =============
        function fillDemo(email, password) {
            document.getElementById('emailInput').value = email;
            document.getElementById('passwordInput').value = password;
            const btn = document.getElementById('signinBtn');
            if (btn) {
                btn.disabled = true;
                btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span> Signing in…';
            }
            document.getElementById('loginForm').submit();
        }

        // Initialize slideshow when page loads
        initSlideshow();
    </script>
</body>
</html>
