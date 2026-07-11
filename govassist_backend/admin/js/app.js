// Check authentication
const adminUser = JSON.parse(sessionStorage.getItem('govassist_admin'));
if (!adminUser && !window.location.href.includes('login.html')) {
    window.location.href = 'login.html';
}

const mainContent = document.getElementById('mainContent');
const modalOverlay = document.getElementById('adminModal');
const modalTitle = document.getElementById('modalTitle');
const modalBody = document.getElementById('modalBody');
const pageTitle = document.getElementById('pageTitle');
const userNameDisplay = document.getElementById('userNameDisplay');
const userAvatar = document.getElementById('userAvatar');

if (adminUser && userNameDisplay && userAvatar) {
    userNameDisplay.textContent = adminUser.full_name;
    if (adminUser.profile_picture) {
        userAvatar.innerHTML = `<img src="../${adminUser.profile_picture}" style="width: 100%; height: 100%; object-fit: cover; border-radius: 50%;">`;
    } else {
        userAvatar.textContent = adminUser.full_name.charAt(0).toUpperCase();
    }
}

function escapeHTML(str) {
    if (!str) return '';
    return str.toString()
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

// Navigation
document.querySelectorAll('.nav-item').forEach(item => {
    item.addEventListener('click', (e) => {
        let target = e.target;
        while (!target.classList.contains('nav-item')) {
            target = target.parentElement;
        }

        if(target.id === 'logoutBtn') {
            sessionStorage.removeItem('govassist_admin');
            sessionStorage.removeItem('govassist_current_view');
            window.location.href = 'login.html';
            return;
        }
        
        document.querySelectorAll('.nav-item').forEach(nav => nav.classList.remove('active'));
        target.classList.add('active');
        const view = target.dataset.view;
        sessionStorage.setItem('govassist_current_view', view);
        loadView(view);
    });
});

async function loadView(view) {
    mainContent.innerHTML = '<div style="text-align:center; padding: 3rem; color: var(--text-secondary);">Loading...</div>';
    
    if (view === 'dashboard') {
        if(pageTitle) pageTitle.textContent = 'Dashboard Overview';
        await renderDashboard();
    } else if (view === 'services') {
        if(pageTitle) pageTitle.textContent = 'Manage Services';
        await renderServices();
    } else if (view === 'requirements') {
        if(pageTitle) pageTitle.textContent = 'Manage Requirements';
        await renderRequirements();
    } else if (view === 'eligibility') {
        if(pageTitle) pageTitle.textContent = 'Manage Eligibility Questions';
        await renderEligibility();
    } else if (view === 'faqs') {
        if(pageTitle) pageTitle.textContent = 'Manage FAQs';
        await renderFAQs();
    } else if (view === 'inquiries') {
        if(pageTitle) pageTitle.textContent = 'Inquiries & Support';
        await renderInquiries();
    } else if (view === 'users') {
        if(pageTitle) pageTitle.textContent = 'Manage Users';
        await renderUsers();
    } else if (view === 'assessments') {
        if(pageTitle) pageTitle.textContent = 'Manage Assessments';
        await renderAssessments();
    } else if (view === 'documents') {
        if(pageTitle) pageTitle.textContent = 'Manage Documents';
        await renderDocuments();
    } else if (view === 'templates') {
        if(pageTitle) pageTitle.textContent = 'Document Templates';
        await renderTemplates();
    } else if (view === 'announcements') {
        if(pageTitle) pageTitle.textContent = 'Manage Announcements';
        await renderAnnouncements();
    } else if (view === 'settings') {
        if(pageTitle) pageTitle.textContent = 'System Settings';
        await renderSettings();
    } else if (view === 'profile') {
        if(pageTitle) pageTitle.textContent = 'My Profile';
        await renderProfile();
    }
}

// Views
async function renderProfile() {
    mainContent.innerHTML = `
        <div style="max-width: 600px; margin: 0 auto;">
            <div class="glass-panel" style="padding: 2.5rem; text-align: center; border-radius: 20px 20px 0 0; background: linear-gradient(135deg, #B91C1C 0%, #EF4444 100%); color: white; box-shadow: 0 10px 25px -5px rgba(185, 28, 28, 0.3);">
                <div style="position: relative; width: 100px; height: 100px; margin: 0 auto 1.5rem auto;">
                    <div id="profile_image_preview" style="width: 100%; height: 100%; border-radius: 50%; background: white; color: #B91C1C; display: flex; align-items: center; justify-content: center; font-size: 3.5rem; font-weight: 700; box-shadow: 0 4px 10px rgba(0,0,0,0.2); overflow: hidden;">
                        ${adminUser.profile_picture ? `<img src="../${adminUser.profile_picture}" style="width:100%; height:100%; object-fit:cover;">` : adminUser.full_name.charAt(0).toUpperCase()}
                    </div>
                    <label for="profile_picture" style="position: absolute; bottom: 0; right: -5px; background: #ffffff; color: #B91C1C; width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center; cursor: pointer; box-shadow: 0 4px 10px rgba(0,0,0,0.2); border: 2px solid #B91C1C; transition: transform 0.2s;" onmouseover="this.style.transform='scale(1.1)'" onmouseout="this.style.transform='scale(1)'">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"></path><circle cx="12" cy="13" r="4"></circle></svg>
                    </label>
                    <input type="file" id="profile_picture" accept="image/*" style="display: none;" onchange="
                        const file = this.files[0];
                        if(file) {
                            const reader = new FileReader();
                            reader.onload = function(e) {
                                document.getElementById('profile_image_preview').innerHTML = '<img src=\\'' + e.target.result + '\\' style=\\'width:100%; height:100%; object-fit:cover;\\'>';
                            }
                            reader.readAsDataURL(file);
                        }
                    ">
                </div>
                <h2 style="font-size: 1.75rem; color: white; margin-bottom: 0.25rem;">${adminUser.full_name}</h2>
                <p style="opacity: 0.9;">System Administrator</p>
            </div>
            
            <div class="glass-panel" style="padding: 2.5rem; border-radius: 0 0 20px 20px; border-top: none;">
                <form id="profileForm" onsubmit="updateAdminProfile(event)">
                    <input type="hidden" id="profile_id" value="${adminUser.id}">
                    
                    <div class="form-group">
                        <label for="profile_name">Full Name</label>
                        <input type="text" id="profile_name" class="form-control" value="${adminUser.full_name}" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="profile_email">Email Address</label>
                        <input type="email" id="profile_email" class="form-control" value="${adminUser.email}" required>
                    </div>
                    
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
                        <div class="form-group">
                            <label for="profile_contact">Contact Number</label>
                            <input type="text" id="profile_contact" class="form-control" value="${adminUser.contact_number || ''}">
                        </div>
                        <div class="form-group">
                            <label for="profile_dob">Date of Birth</label>
                            <input type="date" id="profile_dob" class="form-control" value="${adminUser.dob || ''}">
                        </div>
                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
                        <div class="form-group">
                            <label for="profile_address">Address</label>
                            <input type="text" id="profile_address" class="form-control" value="${adminUser.address || ''}">
                        </div>
                        <div class="form-group">
                            <label for="profile_civil_status">Civil Status</label>
                            <select id="profile_civil_status" class="form-control">
                                <option value="" ${!adminUser.civil_status ? 'selected' : ''}>Select Status</option>
                                <option value="Single" ${adminUser.civil_status === 'Single' ? 'selected' : ''}>Single</option>
                                <option value="Married" ${adminUser.civil_status === 'Married' ? 'selected' : ''}>Married</option>
                                <option value="Widowed" ${adminUser.civil_status === 'Widowed' ? 'selected' : ''}>Widowed</option>
                                <option value="Divorced" ${adminUser.civil_status === 'Divorced' ? 'selected' : ''}>Divorced</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="profile_password">New Password (leave blank to keep current)</label>
                        <input type="password" id="profile_password" class="form-control" placeholder="••••••••">
                    </div>
                    
                    <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 1rem; padding: 1rem; font-size: 1.1rem;">Save Changes</button>
                </form>
            </div>
        </div>
    `;
}

window.updateAdminProfile = async function(e) {
    e.preventDefault();
    const btn = e.target.querySelector('button');
    const originalText = btn.textContent;
    btn.textContent = 'Saving...';
    btn.disabled = true;
    
    try {
        const formData = new FormData();
        formData.append('id', document.getElementById('profile_id').value);
        formData.append('full_name', document.getElementById('profile_name').value);
        formData.append('email', document.getElementById('profile_email').value);
        formData.append('contact_number', document.getElementById('profile_contact').value);
        formData.append('dob', document.getElementById('profile_dob').value);
        formData.append('address', document.getElementById('profile_address').value);
        formData.append('civil_status', document.getElementById('profile_civil_status').value);
        formData.append('password', document.getElementById('profile_password').value);
        
        const fileInput = document.getElementById('profile_picture');
        if (fileInput && fileInput.files.length > 0) {
            formData.append('profile_picture', fileInput.files[0]);
        }
        
        const res = await fetch('../api/admin/update_profile.php', {
            method: 'POST',
            headers: {
                'Authorization': 'Bearer ' + sessionStorage.getItem('govassist_token')
            },
            body: formData
        });
        
        const data = await res.json();
        
        if (data.success) {
            alert('Profile updated successfully!');
            // Update local user cache
            window.adminUser = data.user;
            sessionStorage.setItem('govassist_admin', JSON.stringify(data.user));
            document.getElementById('userNameDisplay').textContent = data.user.full_name;
            
            const userAvatar = document.getElementById('userAvatar');
            if (data.user.profile_picture) {
                userAvatar.innerHTML = '<img src="../' + data.user.profile_picture + '" style="width: 100%; height: 100%; object-fit: cover; border-radius: 50%;">';
            } else {
                userAvatar.textContent = data.user.full_name.charAt(0).toUpperCase();
            }
            
            document.getElementById('profile_password').value = '';
        } else {
            alert(data.error || 'Failed to update profile');
        }
    } catch(err) {
        alert('An error occurred');
    }
    
    btn.textContent = originalText;
    btn.disabled = false;
};

async function renderDashboard() {
    try {
        const res = await fetch('../api/admin/admin_stats.php');
        const stats = await res.json();
        
        mainContent.innerHTML = `
            <div style="margin-bottom: 2.5rem; padding: 3rem; border-radius: 20px; background: linear-gradient(135deg, #B91C1C 0%, #EF4444 100%); color: white; position: relative; overflow: hidden; box-shadow: 0 10px 25px -5px rgba(185, 28, 28, 0.4);">
                <!-- Decorative background circles -->
                <div style="position: absolute; top: -50px; right: -50px; width: 250px; height: 250px; border-radius: 50%; background: rgba(255, 255, 255, 0.1);"></div>
                <div style="position: absolute; bottom: -80px; right: 100px; width: 150px; height: 150px; border-radius: 50%; background: rgba(255, 255, 255, 0.1);"></div>
                
                <h2 style="font-size: 2.5rem; margin-bottom: 0.75rem; color: white; position: relative; z-index: 1;">Welcome back, ${adminUser ? adminUser.full_name : 'Admin'}! 👋</h2>
                <p style="font-size: 1.15rem; opacity: 0.95; position: relative; z-index: 1; max-width: 650px; line-height: 1.6;">Here's your system overview for today. Click on any of the cards below to quickly navigate to that section.</p>
            </div>

            <div class="glass-panel" style="display: flex; border-radius: 20px; overflow: hidden; box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.05); background: white;">
                <!-- Users Stat -->
                <div onclick="document.querySelector('[data-view=\\'users\\']').click()" style="flex: 1; padding: 2.5rem; border-right: 1px solid var(--border-color); cursor: pointer; transition: background 0.2s;" onmouseover="this.style.background='#f8fafc'" onmouseout="this.style.background='transparent'">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 1.5rem;">
                        <div>
                            <div class="stat-label" style="font-size: 0.85rem; color: var(--text-secondary); margin-bottom: 0.5rem;">Total Users</div>
                            <div class="stat-value" style="font-size: 2.75rem; color: var(--text-primary); line-height: 1; margin: 0;">${stats.totalUsers || 0}</div>
                        </div>
                        <div style="width: 52px; height: 52px; border-radius: 14px; background: rgba(59, 130, 246, 0.1); color: #3B82F6; display: flex; align-items: center; justify-content: center;">
                            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                        </div>
                    </div>
                    <div style="display: flex; align-items: center; gap: 8px; font-size: 0.85rem;">
                        <span style="color: #10B981; display: flex; align-items: center; font-weight: 700; background: rgba(16, 185, 129, 0.1); padding: 4px 8px; border-radius: 20px;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px;"><polyline points="22 7 13.5 15.5 8.5 10.5 2 17"></polyline><polyline points="16 7 22 7 22 13"></polyline></svg> +12.5%</span>
                        <span style="color: #94a3b8; font-weight: 500;">vs last month</span>
                    </div>
                </div>

                <!-- Services Stat -->
                <div onclick="document.querySelector('[data-view=\\'services\\']').click()" style="flex: 1; padding: 2.5rem; border-right: 1px solid var(--border-color); cursor: pointer; transition: background 0.2s;" onmouseover="this.style.background='#f8fafc'" onmouseout="this.style.background='transparent'">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 1.5rem;">
                        <div>
                            <div class="stat-label" style="font-size: 0.85rem; color: var(--text-secondary); margin-bottom: 0.5rem;">Gov Services</div>
                            <div class="stat-value" style="font-size: 2.75rem; color: var(--text-primary); line-height: 1; margin: 0;">${stats.totalServices || 0}</div>
                        </div>
                        <div style="width: 52px; height: 52px; border-radius: 14px; background: rgba(139, 92, 246, 0.1); color: #8B5CF6; display: flex; align-items: center; justify-content: center;">
                            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path></svg>
                        </div>
                    </div>
                    <div style="display: flex; align-items: center; gap: 8px; font-size: 0.85rem;">
                        <span style="color: #10B981; display: flex; align-items: center; font-weight: 700; background: rgba(16, 185, 129, 0.1); padding: 4px 8px; border-radius: 20px;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px;"><polyline points="22 7 13.5 15.5 8.5 10.5 2 17"></polyline><polyline points="16 7 22 7 22 13"></polyline></svg> +4.2%</span>
                        <span style="color: #94a3b8; font-weight: 500;">vs last month</span>
                    </div>
                </div>

                <!-- Inquiries Stat -->
                <div onclick="document.querySelector('[data-view=\\'inquiries\\']').click()" style="flex: 1; padding: 2.5rem; border-right: 1px solid var(--border-color); cursor: pointer; transition: background 0.2s;" onmouseover="this.style.background='#f8fafc'" onmouseout="this.style.background='transparent'">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 1.5rem;">
                        <div>
                            <div class="stat-label" style="font-size: 0.85rem; color: var(--text-secondary); margin-bottom: 0.5rem;">Open Inquiries</div>
                            <div class="stat-value" style="font-size: 2.75rem; color: var(--text-primary); line-height: 1; margin: 0;">${stats.openInquiries || 0}</div>
                        </div>
                        <div style="width: 52px; height: 52px; border-radius: 14px; background: rgba(16, 185, 129, 0.1); color: #10B981; display: flex; align-items: center; justify-content: center;">
                            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path></svg>
                        </div>
                    </div>
                    <div style="display: flex; align-items: center; gap: 8px; font-size: 0.85rem;">
                        <span style="color: #EF4444; display: flex; align-items: center; font-weight: 700; background: rgba(239, 68, 68, 0.1); padding: 4px 8px; border-radius: 20px;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px;"><polyline points="22 17 13.5 8.5 8.5 13.5 2 7"></polyline><polyline points="16 17 22 17 22 11"></polyline></svg> -2.1%</span>
                        <span style="color: #94a3b8; font-weight: 500;">vs last month</span>
                    </div>
                </div>

                <!-- Assessments Stat -->
                <div onclick="document.querySelector('[data-view=\\'assessments\\']').click()" style="flex: 1; padding: 2.5rem; cursor: pointer; transition: background 0.2s;" onmouseover="this.style.background='#f8fafc'" onmouseout="this.style.background='transparent'">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 1.5rem;">
                        <div>
                            <div class="stat-label" style="font-size: 0.85rem; color: var(--text-secondary); margin-bottom: 0.5rem;">Assessments</div>
                            <div class="stat-value" style="font-size: 2.75rem; color: var(--text-primary); line-height: 1; margin: 0;">${stats.totalAssessments || 0}</div>
                        </div>
                        <div style="width: 52px; height: 52px; border-radius: 14px; background: rgba(245, 158, 11, 0.1); color: #F59E0B; display: flex; align-items: center; justify-content: center;">
                            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 11 12 14 22 4"></polyline><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"></path></svg>
                        </div>
                    </div>
                    <div style="display: flex; align-items: center; gap: 8px; font-size: 0.85rem;">
                        <span style="color: #10B981; display: flex; align-items: center; font-weight: 700; background: rgba(16, 185, 129, 0.1); padding: 4px 8px; border-radius: 20px;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px;"><polyline points="22 7 13.5 15.5 8.5 10.5 2 17"></polyline><polyline points="16 7 22 7 22 13"></polyline></svg> +18.4%</span>
                        <span style="color: #94a3b8; font-weight: 500;">vs last month</span>
                    </div>
                </div>
            </div>
        `;
    } catch(err) {
        mainContent.innerHTML = 'Error loading dashboard.';
    }
}

async function renderServices() {
    try {
        const [res, reqRes] = await Promise.all([
            fetch('../api/admin/manage_services.php'),
            fetch('../api/admin/manage_requirements.php')
        ]);
        
        const services = await res.json();
        const allReqs = await reqRes.json();
        
        window.currentServices = services;
        window.currentRequirements = allReqs;
        
        let html = `
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
                <h1>Manage Services</h1>
                <button class="btn btn-primary" onclick="showAddServiceModal()">+ Add New Service</button>
            </div>
            <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 1.5rem;">
        `;
        
        if (services.length === 0) {
            html += `<div style="grid-column: 1 / -1; text-align: center; padding: 3rem; color: var(--text-secondary);" class="glass-panel">No services found. Click "+ Add New Service" to create one.</div>`;
        }
        
        services.forEach(srv => {
            const reqs = allReqs.filter(r => r.service_id === srv.id);
            let reqsHtml = reqs.length > 0
                ? `<ul style="list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 0.4rem;">${reqs.slice(0, 3).map(r => `<li style="font-size: 0.85rem; color: var(--text-secondary); display: flex; align-items: flex-start; gap: 8px;"><span style="color: #D1D5DB; font-size: 1.1rem; line-height: 1;">•</span> <span style="line-height: 1.4;">${r.name}</span></li>`).join('')}${reqs.length > 3 ? `<li style="font-size: 0.8rem; color: var(--primary-color); font-weight: 500; margin-top: 4px; padding-left: 16px;">+ ${reqs.length - 3} more</li>` : ''}</ul>`
                : '<div style="font-size: 0.85rem; color: #9CA3AF; font-style: italic; padding-left: 4px;">No requirements specified</div>';
                
            html += `
                <div class="glass-panel" style="padding: 1.5rem; display: flex; flex-direction: column; background: white; border: 1px solid var(--border-color); box-shadow: 0 1px 3px rgba(0,0,0,0.05); transition: transform 0.2s ease, box-shadow 0.2s ease;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 6px -1px rgba(0,0,0,0.1)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 1px 3px rgba(0,0,0,0.05)';">
                    <div style="margin-bottom: 0.75rem;">
                        <h3 style="font-size: 1.25rem; font-weight: 700; color: var(--text-primary); margin: 0; line-height: 1.3; letter-spacing: -0.01em;">${srv.title}</h3>
                    </div>
                    
                    <div style="margin-bottom: 1.5rem;">
                        <span style="display: block; font-size: 0.75rem; font-weight: 700; color: #9CA3AF; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 0.25rem;">Description</span>
                        <p style="color: var(--text-secondary); font-size: 0.9rem; line-height: 1.5; margin: 0; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">${srv.description || '<span style="font-style:italic; opacity:0.6;">No description provided</span>'}</p>
                    </div>
                    
                    <div style="margin-bottom: 1.5rem; flex: 1;">
                        <div style="display: flex; align-items: center; gap: 6px; margin-bottom: 0.75rem;">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="color: var(--primary-color);"><path d="M9 11l3 3L22 4"></path><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"></path></svg>
                            <span style="font-size: 0.75rem; font-weight: 700; color: var(--text-primary); text-transform: uppercase; letter-spacing: 0.05em;">Requirements</span>
                        </div>
                        ${reqsHtml}
                    </div>
                    
                    <div style="display: flex; gap: 0.5rem; border-top: 1px solid var(--border-color); padding-top: 1.25rem; margin-top: auto;">
                        <button class="btn" onclick="showEditServiceModal('${srv.id}')" style="flex: 1; background: #F3F4F6; color: var(--text-primary); border: 1px solid #E5E7EB; font-weight: 600; font-size: 0.85rem; transition: all 0.2s ease;" onmouseover="this.style.background='#E5E7EB'" onmouseout="this.style.background='#F3F4F6'">Edit Service</button>
                        
                        <button class="btn" onclick="deleteService('${srv.id}')" style="padding: 0 0.75rem; background: #FEF2F2; color: var(--danger-color); border: 1px solid #FECACA; display: flex; align-items: center; justify-content: center; transition: all 0.2s ease;" onmouseover="this.style.background='#FEE2E2'" onmouseout="this.style.background='#FEF2F2'" title="Delete Service">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg>
                        </button>
                    </div>
                </div>
            `;
        });
        
        html += `</div>`;
        mainContent.innerHTML = html;
    } catch(err) {
        mainContent.innerHTML = 'Error loading services.';
    }
}

async function renderInquiries() {
    try {
        const res = await fetch('../api/admin/manage_inquiries.php');
        const inquiries = await res.json();
        
        let html = `
            <h1>Inquiries & Support</h1>
            <div class="data-table-container glass-panel">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Subject</th>
                            <th>Status</th>
                            <th>Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
        `;
        
        inquiries.forEach(inq => {
            const badgeClass = inq.status === 'Open' ? 'badge-open' : 'badge-closed';
            html += `
                <tr>
                    <td style="font-weight: 500;">${inq.subject}</td>
                    <td><span class="badge ${badgeClass}">${inq.status}</span></td>
                    <td>${new Date(inq.date_submitted).toLocaleDateString()}</td>
                    <td>
                        <button class="btn btn-primary" onclick="showRespondModal('${inq.id}', '${inq.subject.replace(/'/g, "\\'")}')" style="padding: 0.4rem 0.8rem; font-size: 0.8rem;">Respond</button>
                    </td>
                </tr>
            `;
        });
        
        html += `</tbody></table></div>`;
        mainContent.innerHTML = html;
    } catch(err) {
        mainContent.innerHTML = 'Error loading inquiries.';
    }
}

async function renderRequirements() {
    try {
        const res = await fetch('../api/admin/manage_requirements.php');
        const requirements = await res.json();
        
        let html = `
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
                <h1>Manage Requirements</h1>
                <button class="btn btn-primary" onclick="showAddRequirementModal()">+ Add Requirement</button>
            </div>
        `;
        
        if (requirements.length === 0) {
            html += `<div class="glass-panel" style="padding: 3rem; text-align: center; color: var(--text-secondary);">No requirements found.</div>`;
        } else {
            // Group by service
            const grouped = {};
            requirements.forEach(req => {
                const svc = req.service_title || req.service_id || 'Unknown Service';
                if (!grouped[svc]) grouped[svc] = [];
                grouped[svc].push(req);
            });
            
            for (const [serviceName, reqs] of Object.entries(grouped)) {
                html += `
                    <div class="glass-panel" style="margin-bottom: 2rem; overflow: hidden;">
                        <div style="background: #F9FAFB; padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border-color); display: flex; align-items: center; gap: 8px;">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--primary-color)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                            <h3 style="margin: 0; color: var(--text-primary); font-size: 1.1rem; font-weight: 600;">${serviceName}</h3>
                        </div>
                        <div class="data-table-container">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Requirement Name</th>
                                        <th style="width: 120px;">Required?</th>
                                        <th style="width: 80px;">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                `;
                
                reqs.forEach(req => {
                    html += `
                        <tr>
                            <td style="font-weight: 500;">${req.name}</td>
                            <td><span class="badge ${req.is_required == 1 ? 'badge-open' : 'badge-closed'}">${req.is_required == 1 ? 'Yes' : 'No'}</span></td>
                            <td>
                                <button class="btn" onclick="deleteRequirement('${req.id}')" style="padding: 0.4rem 0.6rem; background: #FEF2F2; color: var(--danger-color); border: 1px solid #FECACA; display: flex; align-items: center; justify-content: center; border-radius: 6px; transition: all 0.2s ease;" onmouseover="this.style.background='#FEE2E2'" onmouseout="this.style.background='#FEF2F2'" title="Delete">
                                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg>
                                </button>
                            </td>
                        </tr>
                    `;
                });
                
                html += `</tbody></table></div></div>`;
            }
        }
        
        mainContent.innerHTML = html;
    } catch(err) {
        mainContent.innerHTML = 'Error loading requirements.';
    }
}

async function renderEligibility() {
    try {
        const res = await fetch('../api/admin/manage_eligibility.php');
        const questions = await res.json();
        
        let html = `
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
                <h1>Manage Eligibility Questions</h1>
                <button class="btn btn-primary" onclick="showAddEligibilityModal()">+ Add Question</button>
            </div>
        `;
        
        if (questions.length === 0) {
            html += `<div class="glass-panel" style="padding: 3rem; text-align: center; color: var(--text-secondary);">No eligibility questions found.</div>`;
        } else {
            const grouped = {};
            questions.forEach(q => {
                const svc = q.service_title || q.service_id || 'Unknown Service';
                if (!grouped[svc]) grouped[svc] = [];
                grouped[svc].push(q);
            });
            
            for (const [serviceName, qs] of Object.entries(grouped)) {
                html += `
                    <div class="glass-panel" style="margin-bottom: 2rem; overflow: hidden;">
                        <div style="background: #F9FAFB; padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border-color); display: flex; align-items: center; gap: 8px;">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--primary-color)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>
                            <h3 style="margin: 0; color: var(--text-primary); font-size: 1.1rem; font-weight: 600;">${serviceName}</h3>
                        </div>
                        <div class="data-table-container">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Question</th>
                                        <th style="width: 150px;">Expected Answer</th>
                                        <th style="width: 80px;">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                `;
                
                qs.forEach(q => {
                    let ansDisplay = '';
                    if (q.options) {
                        let opts = [];
                        try { opts = typeof q.options === 'string' ? JSON.parse(q.options) : q.options; } catch(e){}
                        if (!Array.isArray(opts)) opts = [];
                        ansDisplay = `<div style="font-size: 0.8rem; color: var(--text-secondary); margin-bottom: 4px;">[${opts.join(', ')}]</div>
                                      <span class="badge" style="background:#E0E7FF; color:#3730A3;">Survey Type</span>`;
                    } else {
                        ansDisplay = `<span class="badge ${q.expected_answer == 1 || q.expected_answer == '1' ? 'badge-open' : 'badge-closed'}">${q.expected_answer == 1 || q.expected_answer == '1' ? 'Yes' : 'No'}</span>`;
                    }
                    html += `
                        <tr>
                            <td style="font-weight: 500;">${q.question_text}</td>
                            <td>${ansDisplay}</td>
                            <td>
                                <div style="display: flex; gap: 8px;">
                                    <button class="btn" onclick='showEditEligibilityModal(${JSON.stringify(q).replace(/&/g, "&amp;").replace(/'/g, "&#39;").replace(/"/g, "&quot;")})' style="padding: 0.4rem 0.6rem; background: #EFF6FF; color: var(--primary-color); border: 1px solid #DBEAFE; display: flex; align-items: center; justify-content: center; border-radius: 6px; transition: all 0.2s ease;" onmouseover="this.style.background='#DBEAFE'" onmouseout="this.style.background='#EFF6FF'" title="Edit">
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                                    </button>
                                    <button class="btn" onclick="deleteEligibility('${q.id}')" style="padding: 0.4rem 0.6rem; background: #FEF2F2; color: var(--danger-color); border: 1px solid #FECACA; display: flex; align-items: center; justify-content: center; border-radius: 6px; transition: all 0.2s ease;" onmouseover="this.style.background='#FEE2E2'" onmouseout="this.style.background='#FEF2F2'" title="Delete">
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg>
                                    </button>
                                </div>
                            </td>
                        </tr>
                    `;
                });
                
                html += `</tbody></table></div></div>`;
            }
        }
        
        mainContent.innerHTML = html;
    } catch(err) {
        mainContent.innerHTML = 'Error loading eligibility questions.';
    }
}

async function renderFAQs() {
    try {
        const res = await fetch('../api/admin/manage_faqs.php');
        const faqs = await res.json();
        
        let html = `
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
                <h1>Manage FAQs</h1>
                <button class="btn btn-primary" onclick="showAddFAQModal()">+ Add FAQ</button>
            </div>
            <div class="data-table-container glass-panel">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Question</th>
                            <th>Answer</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
        `;
        
        faqs.forEach(faq => {
            html += `
                <tr>
                    <td style="font-weight: 500;">${faq.question}</td>
                    <td>${faq.answer}</td>
                    <td>
                        <button class="btn btn-danger" onclick="deleteFAQ('${faq.id}')" style="padding: 0.4rem 0.8rem; font-size: 0.8rem;">Delete</button>
                    </td>
                </tr>
            `;
        });
        
        html += `</tbody></table></div>`;
        mainContent.innerHTML = html;
    } catch(err) {
        mainContent.innerHTML = 'Error loading FAQs.';
    }
}

async function renderUsers() {
    try {
        const res = await fetch('../api/admin/manage_users.php');
        const users = await res.json();
        
        let html = `
            <h1>Manage Users</h1>
            <div class="data-table-container glass-panel">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Joined</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
        `;
        
        users.forEach(user => {
            html += `
                <tr>
                    <td>${user.id}</td>
                    <td style="font-weight: 500;">${user.full_name}</td>
                    <td>${user.email}</td>
                    <td>${new Date(user.created_at).toLocaleDateString()}</td>
                    <td>
                        <button class="btn btn-danger" onclick="deleteUser('${user.id}')" style="padding: 0.4rem 0.8rem; font-size: 0.8rem;">Delete</button>
                    </td>
                </tr>
            `;
        });
        
        html += `</tbody></table></div>`;
        mainContent.innerHTML = html;
    } catch(err) {
        mainContent.innerHTML = 'Error loading users.';
    }
}

async function renderAssessments() {
    try {
        const res = await fetch('../api/admin/manage_assessments.php');
        const assessments = await res.json();
        
        let html = `
            <h1>Manage Assessments</h1>
        `;
        
        if (assessments.length === 0) {
            html += `<div class="glass-panel" style="padding: 3rem; text-align: center; color: var(--text-secondary);">No assessments found.</div>`;
        } else {
            const grouped = {};
            assessments.forEach(ass => {
                const svc = ass.service_title || ass.service_id || 'Unknown Service';
                if (!grouped[svc]) grouped[svc] = [];
                grouped[svc].push(ass);
            });
            
            for (const [serviceName, asss] of Object.entries(grouped)) {
                html += `
                    <div class="glass-panel" style="margin-bottom: 2rem; overflow: hidden;">
                        <div style="background: #F9FAFB; padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border-color); display: flex; align-items: center; gap: 8px;">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--primary-color)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 11 12 14 22 4"></polyline><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"></path></svg>
                            <h3 style="margin: 0; color: var(--text-primary); font-size: 1.1rem; font-weight: 600;">${serviceName}</h3>
                        </div>
                        <div class="data-table-container">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Reference No.</th>
                                        <th>Eligible?</th>
                                        <th>Date Taken</th>
                                    </tr>
                                </thead>
                                <tbody>
                `;
                
                asss.forEach(ass => {
                    html += `
                        <tr>
                            <td style="font-weight: 500;">${ass.reference_number}</td>
                            <td><span class="badge ${ass.is_eligible == 1 ? 'badge-open' : 'badge-closed'}">${ass.is_eligible == 1 ? 'Yes' : 'No'}</span></td>
                            <td>${new Date(ass.date).toLocaleString()}</td>
                        </tr>
                    `;
                });
                
                html += `</tbody></table></div></div>`;
            }
        }
        
        mainContent.innerHTML = html;
    } catch(err) {
        mainContent.innerHTML = 'Error loading assessments.';
    }
}

async function renderDocuments() {
    try {
        const [resDocs, resTemps] = await Promise.all([
            fetch('../api/admin/manage_documents.php'),
            fetch('../api/admin/manage_templates.php')
        ]);
        const documents = await resDocs.json();
        const templates = await resTemps.json();
        
        let html = `
            <h1>Manage Documents</h1>
        `;
        
        if (documents.length === 0) {
            html += `<div class="glass-panel" style="padding: 3rem; text-align: center; color: var(--text-secondary);">No documents found.</div>`;
        } else {
            const grouped = {};
            documents.forEach(doc => {
                const svc = doc.service_title || doc.service_id || 'Unknown Service';
                if (!grouped[svc]) grouped[svc] = [];
                grouped[svc].push(doc);
            });
            
            for (const [serviceName, docs] of Object.entries(grouped)) {
                // Find template for this service
                const serviceTemplates = templates.filter(t => t.service_title === serviceName || t.service_id === docs[0].service_id);
                let templateButtons = '';
                if (serviceTemplates.length > 0) {
                    serviceTemplates.forEach(t => {
                        templateButtons += `<a href="../${t.file_path}" target="_blank" class="badge badge-open" style="text-decoration:none; margin-left: 10px;">📋 View Template: ${t.title}</a>`;
                    });
                } else {
                    templateButtons = `<span class="badge badge-closed" style="margin-left: 10px;">No templates available</span>`;
                }

                html += `
                    <div class="glass-panel" style="margin-bottom: 2rem; overflow: hidden;">
                        <div style="background: #F9FAFB; padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border-color); display: flex; align-items: center; gap: 8px;">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--primary-color)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path></svg>
                            <h3 style="margin: 0; color: var(--text-primary); font-size: 1.1rem; font-weight: 600;">${serviceName}</h3>
                            ${templateButtons}
                        </div>
                        <div class="data-table-container">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>User</th>
                                        <th>Requirement</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                `;
                
                docs.forEach(doc => {
                    let badgeClass = 'badge-closed';
                    if (doc.verification_status === 'Verified') badgeClass = 'badge-open';
                    if (doc.verification_status === 'Pending') badgeClass = '';
                    
                    html += `
                        <tr>
                            <td style="font-weight: 500;">${doc.full_name}<br><small style="color:var(--text-secondary);">${doc.email}</small></td>
                            <td>${doc.requirement_name}</td>
                            <td><span class="badge ${badgeClass}" style="${doc.verification_status === 'Pending' ? 'background:#FDE68A; color:#92400E;' : ''}">${doc.verification_status}</span></td>
                            <td>
                                <select onchange="updateDocStatus('${doc.id}', this.value)" class="form-control" style="padding: 0.3rem; display: inline-block; width: auto; font-size: 0.8rem;">
                                    <option value="Pending" ${doc.verification_status === 'Pending' ? 'selected' : ''}>Pending</option>
                                    <option value="Verified" ${doc.verification_status === 'Verified' ? 'selected' : ''}>Verified</option>
                                    <option value="Rejected" ${doc.verification_status === 'Rejected' ? 'selected' : ''}>Rejected</option>
                                </select>
                                <a href="../${doc.file_path}" target="_blank" class="btn btn-primary" style="padding: 0.4rem 0.8rem; font-size: 0.8rem; text-decoration: none; display: inline-block;">View</a>
                            </td>
                        </tr>
                    `;
                });
                
                html += `</tbody></table></div></div>`;
            }
        }
        
        mainContent.innerHTML = html;
    } catch(err) {
        mainContent.innerHTML = 'Error loading documents.';
    }
}

async function renderTemplates() {
    try {
        const [resTemps, resSvcs] = await Promise.all([
            fetch('../api/admin/manage_templates.php'),
            fetch('../api/services.php')
        ]);
        const templates = await resTemps.json();
        const servicesResponse = await resSvcs.json();
        const services = servicesResponse.data || servicesResponse; // Fallback depending on API structure
        
        let html = `
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
                <h1>Document Templates</h1>
                <button class="btn btn-primary" onclick="showAddTemplateModal()">+ Add Template</button>
            </div>
        `;
        
        if (templates.length === 0) {
            html += `<div class="glass-panel" style="padding: 3rem; text-align: center; color: var(--text-secondary);">No templates found. Upload one to use as a reference for verifying client documents.</div>`;
        } else {
            const grouped = {};
            templates.forEach(t => {
                const svc = t.service_title || t.service_id || 'Unknown Service';
                if (!grouped[svc]) grouped[svc] = [];
                grouped[svc].push(t);
            });
            
            for (const [serviceName, temps] of Object.entries(grouped)) {
                html += `
                    <div class="glass-panel" style="margin-bottom: 2rem; overflow: hidden;">
                        <div style="background: #F9FAFB; padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border-color); display: flex; align-items: center; gap: 8px;">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--primary-color)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><circle cx="8.5" cy="8.5" r="1.5"></circle><polyline points="21 15 16 10 5 21"></polyline></svg>
                            <h3 style="margin: 0; color: var(--text-primary); font-size: 1.1rem; font-weight: 600;">Program: ${serviceName}</h3>
                        </div>
                        <div class="data-table-container">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Template Title</th>
                                        <th>Date Uploaded</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                `;
                
                temps.forEach(t => {
                    html += `
                        <tr>
                            <td style="font-weight: 500;">${t.title}</td>
                            <td>${new Date(t.created_at).toLocaleString()}</td>
                            <td>
                                <a href="../${t.file_path}" target="_blank" class="btn btn-primary" style="padding: 0.4rem 0.8rem; font-size: 0.8rem; text-decoration: none; display: inline-block;">View</a>
                                <button class="btn btn-danger" onclick="deleteTemplate('${t.id}')" style="padding: 0.4rem 0.8rem; font-size: 0.8rem;">Delete</button>
                            </td>
                        </tr>
                    `;
                });
                
                html += `</tbody></table></div></div>`;
            }
        }
        
        mainContent.innerHTML = html;
        
        // Save services globally for modal
        window.adminServicesCache = services;
        
    } catch(err) {
        mainContent.innerHTML = 'Error loading templates.';
    }
}

function showAddTemplateModal() {
    modalTitle.textContent = 'Upload Document Template';
    
    let options = '<option value="">Select a Program / Service</option>';
    if (window.adminServicesCache) {
        window.adminServicesCache.forEach(s => {
            options += `<option value="${s.id}">${s.title}</option>`;
        });
    }
    
    modalBody.innerHTML = `
        <form id="addTemplateForm" enctype="multipart/form-data">
            <div class="form-group">
                <label>Program / Service</label>
                <select id="templateService" class="form-control" required>
                    ${options}
                </select>
            </div>
            <div class="form-group">
                <label>Template Title (e.g. Birth Cert Template)</label>
                <input type="text" id="templateTitle" class="form-control" required>
            </div>
            <div class="form-group">
                <label>Template File (Image/PDF)</label>
                <input type="file" id="templateFile" class="form-control" required accept="image/*,.pdf">
            </div>
            <button type="submit" class="btn btn-primary" style="width: 100%;">Upload Template</button>
        </form>
    `;
    modalOverlay.classList.add('active');
    
    document.getElementById('addTemplateForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const submitBtn = e.target.querySelector('button[type="submit"]');
        submitBtn.disabled = true;
        submitBtn.textContent = 'Uploading...';
        
        const formData = new FormData();
        formData.append('service_id', document.getElementById('templateService').value);
        formData.append('title', document.getElementById('templateTitle').value);
        formData.append('template_file', document.getElementById('templateFile').files[0]);
        
        try {
            const res = await fetch('../api/admin/manage_templates.php', {
                method: 'POST',
                body: formData
            });
            const data = await res.json();
            if(data.success) {
                modalOverlay.classList.remove('active');
                renderTemplates();
            } else {
                alert('Upload failed: ' + data.error);
                submitBtn.disabled = false;
                submitBtn.textContent = 'Upload Template';
            }
        } catch(err) {
            alert('Error connecting to server.');
            submitBtn.disabled = false;
            submitBtn.textContent = 'Upload Template';
        }
    });
}

async function deleteTemplate(id) {
    if(confirm('Are you sure you want to delete this template?')) {
        await fetch('../api/admin/manage_templates.php', {
            method: 'DELETE',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({id})
        });
        renderTemplates();
    }
}

async function renderSettings() {
    mainContent.innerHTML = `
        <h1>System Settings</h1>
        <div class="glass-panel" style="padding: 2rem;">
            <h3>Database Backup</h3>
            <p style="color: var(--text-secondary); margin-bottom: 1rem;">Generate a manual backup of the system database.</p>
            <button class="btn btn-primary" onclick="alert('Backup initiated (Mock)')">Generate SQL Backup</button>
            
            <h3 style="margin-top: 2rem;">System Logs</h3>
            <p style="color: var(--text-secondary); margin-bottom: 1rem;">View raw system error and access logs.</p>
            <button class="btn btn-primary" onclick="alert('Logs exported (Mock)')">Export Logs to CSV</button>
        </div>
    `;
}

// Modal Logic
document.getElementById('closeModal')?.addEventListener('click', () => {
    modalOverlay.classList.remove('active');
});

function showAddServiceModal() {
    modalTitle.textContent = 'Add New Service';
    modalBody.innerHTML = `
        <form id="addServiceForm">
            <div class="form-group">
                <label>Service Title</label>
                <input type="text" id="srvTitle" class="form-control" required>
            </div>
            <div class="form-group">
                <label>Description</label>
                <textarea id="srvDesc" class="form-control" rows="3" required></textarea>
            </div>
            <div class="form-group">
                <label>Requirements (one per line)</label>
                <textarea id="srvReqs" class="form-control" rows="4" placeholder="Enter requirements here..."></textarea>
            </div>
            <button type="submit" class="btn btn-primary" style="width: 100%;">Save Service</button>
        </form>
    `;
    modalOverlay.classList.add('active');
    
    document.getElementById('addServiceForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const data = {
            title: document.getElementById('srvTitle').value,
            description: document.getElementById('srvDesc').value,
            requirements: document.getElementById('srvReqs').value
        };
        
        await fetch('../api/admin/manage_services.php', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(data)
        });
        modalOverlay.classList.remove('active');
        renderServices();
    });
}

async function showEditServiceModal(id) {
    const service = window.currentServices?.find(s => s.id === id);
    if (!service) return;
    
    modalTitle.textContent = 'Edit Service';
    modalBody.innerHTML = '<div style="text-align:center; padding: 2rem;">Loading data...</div>';
    modalOverlay.classList.add('active');
    
    const reqs = window.currentRequirements?.filter(r => r.service_id === id) || [];
    const reqsText = reqs.map(r => r.name).join('\n');
    
    const safeTitle = service.title.replace(/"/g, '&quot;');
    const safeDesc = (service.description || '').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    const safeReqs = reqsText.replace(/</g, '&lt;').replace(/>/g, '&gt;');

    modalBody.innerHTML = `
        <form id="editServiceForm">
            <input type="hidden" id="editSrvId" value="${service.id}">
            <div class="form-group">
                <label>Service Title</label>
                <input type="text" id="editSrvTitle" class="form-control" value="${safeTitle}" required>
            </div>
            <div class="form-group">
                <label>Description</label>
                <textarea id="editSrvDesc" class="form-control" rows="3" required>${safeDesc}</textarea>
            </div>
            <div class="form-group">
                <label>Requirements (one per line)</label>
                <textarea id="editSrvReqs" class="form-control" rows="4" placeholder="Enter requirements here...">${safeReqs}</textarea>
            </div>
            <button type="submit" class="btn btn-primary" style="width: 100%;">Save Changes</button>
        </form>
    `;
    
    document.getElementById('editServiceForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const data = {
            id: document.getElementById('editSrvId').value,
            title: document.getElementById('editSrvTitle').value,
            description: document.getElementById('editSrvDesc').value,
            requirements: document.getElementById('editSrvReqs').value
        };
        
        await fetch('../api/admin/manage_services.php', {
            method: 'PUT',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(data)
        });
        modalOverlay.classList.remove('active');
        renderServices();
    });
}

async function deleteService(id) {
    if(confirm('Are you sure you want to delete this service?')) {
        await fetch('../api/admin/manage_services.php', {
            method: 'DELETE',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({id})
        });
        renderServices();
    }
}

function showRespondModal(ticketId, subject) {
    modalTitle.textContent = 'Respond: ' + subject;
    modalBody.innerHTML = `
        <form id="respondForm">
            <div class="form-group">
                <label>Your Response</label>
                <textarea id="replyText" class="form-control" rows="4" required></textarea>
            </div>
            <div class="form-group">
                <label>Update Status</label>
                <select id="replyStatus" class="form-control">
                    <option value="Closed">Close Inquiry</option>
                    <option value="Open">Keep Open</option>
                </select>
            </div>
            <button type="submit" class="btn btn-primary" style="width: 100%;">Send Response</button>
        </form>
    `;
    modalOverlay.classList.add('active');
    
    document.getElementById('respondForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const data = {
            ticket_id: ticketId,
            message_text: document.getElementById('replyText').value,
            status: document.getElementById('replyStatus').value
        };
        
        await fetch('../api/admin/manage_inquiries.php', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(data)
        });
        modalOverlay.classList.remove('active');
        renderInquiries();
    });
}

// Phase 1 Modals and Logic
function showAddRequirementModal() {
    modalTitle.textContent = 'Add Requirement';
    modalBody.innerHTML = `
        <form id="addRequirementForm">
            <div class="form-group">
                <label>Requirement Name</label>
                <input type="text" id="reqName" class="form-control" required>
            </div>
            <div class="form-group">
                <label>Service ID (e.g. srv_1)</label>
                <input type="text" id="reqServiceId" class="form-control" required>
            </div>
            <div class="form-group">
                <label>Description</label>
                <textarea id="reqDesc" class="form-control" rows="2"></textarea>
            </div>
            <div class="form-group">
                <label>Is Required?</label>
                <select id="reqRequired" class="form-control">
                    <option value="1">Yes</option>
                    <option value="0">No</option>
                </select>
            </div>
            <button type="submit" class="btn btn-primary" style="width: 100%;">Save</button>
        </form>
    `;
    modalOverlay.classList.add('active');
    
    document.getElementById('addRequirementForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const data = {
            name: document.getElementById('reqName').value,
            service_id: document.getElementById('reqServiceId').value,
            description: document.getElementById('reqDesc').value,
            is_required: parseInt(document.getElementById('reqRequired').value)
        };
        await fetch('../api/admin/manage_requirements.php', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(data)
        });
        modalOverlay.classList.remove('active');
        renderRequirements();
    });
}

async function deleteRequirement(id) {
    if(confirm('Delete this requirement?')) {
        await fetch('../api/admin/manage_requirements.php', {
            method: 'DELETE',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({id})
        });
        renderRequirements();
    }
}

async function showAddEligibilityModal() {
    let services = [];
    try {
        const res = await fetch('../api/admin/manage_services.php');
        services = await res.json();
    } catch(e) {}
    
    let serviceOptions = services.map(s => `<option value="${s.id}">${s.title}</option>`).join('');
    
    modalTitle.textContent = 'Add Eligibility Question';
    modalBody.innerHTML = `
        <form id="addEligibilityForm">
            <div class="form-group">
                <label>Question Text</label>
                <textarea id="eligQuestion" class="form-control" rows="2" required></textarea>
            </div>
            <div class="form-group">
                <label>Service</label>
                <select id="eligServiceId" class="form-control" required>
                    ${serviceOptions}
                </select>
            </div>
            <div class="form-group">
                <label>Answer Type</label>
                <select id="eligAnswerType" class="form-control" onchange="toggleAnswerType(this.value)">
                    <option value="yes_no">Yes / No</option>
                    <option value="selection">Selection</option>
                </select>
            </div>
            
            <div id="yesNoContainer" class="form-group">
                <label>Expected Answer</label>
                <select id="eligAnswerYesNo" class="form-control">
                    <option value="1">Yes</option>
                    <option value="0">No</option>
                </select>
            </div>
            
            <div id="selectionContainer" style="display:none;">
                <div class="form-group">
                    <label>Options (comma-separated)</label>
                    <input type="text" id="eligOptions" class="form-control" placeholder="e.g. Student, Employed, Unemployed">
                </div>
            </div>
            
            <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 1rem;">Save</button>
        </form>
    `;
    modalOverlay.classList.add('active');
    
    if (!window.toggleAnswerType) {
        window.toggleAnswerType = function(type) {
            if (type === 'selection') {
                document.getElementById('yesNoContainer').style.display = 'none';
                document.getElementById('selectionContainer').style.display = 'block';
            } else {
                document.getElementById('yesNoContainer').style.display = 'block';
                document.getElementById('selectionContainer').style.display = 'none';
            }
        };
    }
    
    document.getElementById('addEligibilityForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const type = document.getElementById('eligAnswerType').value;
        const data = {
            question_text: document.getElementById('eligQuestion').value,
            service_id: document.getElementById('eligServiceId').value,
        };
        
        if (type === 'yes_no') {
            data.expected_answer = document.getElementById('eligAnswerYesNo').value;
        } else {
            data.expected_answer = '';
            const rawOpts = document.getElementById('eligOptions').value;
            data.options = rawOpts.split(',').map(o => o.trim()).filter(o => o.length > 0);
        }
        
        await fetch('../api/admin/manage_eligibility.php', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(data)
        });
        modalOverlay.classList.remove('active');
        renderEligibility();
    });
}

async function showEditEligibilityModal(q) {
    let services = [];
    try {
        const res = await fetch('../api/admin/manage_services.php');
        services = await res.json();
    } catch(e) {}
    
    let serviceOptions = services.map(s => `<option value="${s.id}" ${s.id === q.service_id ? 'selected' : ''}>${s.title}</option>`).join('');
    
    let isSelection = false;
    let optsArray = [];
    if (q.options) {
        try { optsArray = typeof q.options === 'string' ? JSON.parse(q.options) : q.options; } catch(e){}
        if (Array.isArray(optsArray) && optsArray.length > 0) isSelection = true;
    }
    
    modalTitle.textContent = 'Edit Eligibility Question';
    modalBody.innerHTML = `
        <form id="editEligibilityForm">
            <input type="hidden" id="editEligId" value="${q.id}">
            <div class="form-group">
                <label>Question Text</label>
                <textarea id="eligQuestion" class="form-control" rows="2" required>${q.question_text}</textarea>
            </div>
            <div class="form-group">
                <label>Service</label>
                <select id="eligServiceId" class="form-control" required>
                    ${serviceOptions}
                </select>
            </div>
            <div class="form-group">
                <label>Answer Type</label>
                <select id="eligAnswerType" class="form-control" onchange="toggleAnswerType(this.value)">
                    <option value="yes_no" ${!isSelection ? 'selected' : ''}>Yes / No</option>
                    <option value="selection" ${isSelection ? 'selected' : ''}>Selection</option>
                </select>
            </div>
            
            <div id="yesNoContainer" class="form-group" style="display: ${!isSelection ? 'block' : 'none'};">
                <label>Expected Answer</label>
                <select id="eligAnswerYesNo" class="form-control">
                    <option value="1" ${q.expected_answer == '1' || q.expected_answer == 'Yes' ? 'selected' : ''}>Yes</option>
                    <option value="0" ${q.expected_answer == '0' || q.expected_answer == 'No' ? 'selected' : ''}>No</option>
                </select>
            </div>
            
            <div id="selectionContainer" style="display: ${isSelection ? 'block' : 'none'};">
                <div class="form-group">
                    <label>Options (comma-separated)</label>
                    <input type="text" id="eligOptions" class="form-control" value="${optsArray.join(', ')}">
                </div>
            </div>
            
            <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 1rem;">Update</button>
        </form>
    `;
    modalOverlay.classList.add('active');
    
    if (!window.toggleAnswerType) {
        window.toggleAnswerType = function(type) {
            if (type === 'selection') {
                document.getElementById('yesNoContainer').style.display = 'none';
                document.getElementById('selectionContainer').style.display = 'block';
            } else {
                document.getElementById('yesNoContainer').style.display = 'block';
                document.getElementById('selectionContainer').style.display = 'none';
            }
        };
    }
    
    document.getElementById('editEligibilityForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const type = document.getElementById('eligAnswerType').value;
        const data = {
            id: document.getElementById('editEligId').value,
            question_text: document.getElementById('eligQuestion').value,
            service_id: document.getElementById('eligServiceId').value,
        };
        
        if (type === 'yes_no') {
            data.expected_answer = document.getElementById('eligAnswerYesNo').value;
        } else {
            data.expected_answer = '';
            const rawOpts = document.getElementById('eligOptions').value;
            data.options = rawOpts.split(',').map(o => o.trim()).filter(o => o.length > 0);
        }
        
        await fetch('../api/admin/manage_eligibility.php', {
            method: 'POST', // The PHP script handles update if ID is provided
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(data)
        });
        modalOverlay.classList.remove('active');
        renderEligibility();
    });
}

async function deleteEligibility(id) {
    if(confirm('Delete this question?')) {
        await fetch('../api/admin/manage_eligibility.php', {
            method: 'DELETE',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({id})
        });
        renderEligibility();
    }
}

function showAddFAQModal() {
    modalTitle.textContent = 'Add FAQ';
    modalBody.innerHTML = `
        <form id="addFaqForm">
            <div class="form-group">
                <label>Question</label>
                <input type="text" id="faqQuestion" class="form-control" required>
            </div>
            <div class="form-group">
                <label>Answer</label>
                <textarea id="faqAnswer" class="form-control" rows="3" required></textarea>
            </div>
            <button type="submit" class="btn btn-primary" style="width: 100%;">Save</button>
        </form>
    `;
    modalOverlay.classList.add('active');
    
    document.getElementById('addFaqForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const data = {
            question: document.getElementById('faqQuestion').value,
            answer: document.getElementById('faqAnswer').value
        };
        await fetch('../api/admin/manage_faqs.php', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(data)
        });
        modalOverlay.classList.remove('active');
        renderFAQs();
    });
}

async function deleteFAQ(id) {
    if(confirm('Delete this FAQ?')) {
        await fetch('../api/admin/manage_faqs.php', {
            method: 'DELETE',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({id})
        });
        renderFAQs();
    }
}

async function deleteUser(id) {
    if(confirm('Delete this user account?')) {
        await fetch('../api/admin/manage_users.php', {
            method: 'DELETE',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({id})
        });
        renderUsers();
    }
}

async function updateDocStatus(id, status) {
    await fetch('../api/admin/manage_documents.php', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({id, status})
    });
    // Visual update will happen automatically if they change the dropdown, 
    // but we can re-render to ensure badge colors update
    renderDocuments();
}

// ==========================================
// Announcements Module
// ==========================================
async function renderAnnouncements() {
    mainContent.innerHTML = `
        <div class="header-actions" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem;">
            <h2>Announcements</h2>
            <button class="btn btn-primary" onclick="showAnnouncementModal()">+ Create Announcement</button>
        </div>
        <div class="glass-panel" style="overflow-x: auto;">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Title</th>
                        <th>Content</th>
                        <th>Created At</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="announcementsTableBody">
                    <tr><td colspan="5" style="text-align: center;">Loading announcements...</td></tr>
                </tbody>
            </table>
        </div>
    `;

    try {
        const res = await fetch('../api/admin/manage_announcements.php', {
            headers: {
                'Authorization': 'Bearer ' + sessionStorage.getItem('govassist_token')
            }
        });
        const data = await res.json();
        
        const tbody = document.getElementById('announcementsTableBody');
        
        if (data.success && data.announcements.length > 0) {
            tbody.innerHTML = data.announcements.map(a => `
                <tr>
                    <td>${a.id}</td>
                    <td style="font-weight: 600;">${escapeHTML(a.title)}</td>
                    <td>${escapeHTML(a.content).substring(0, 50)}${a.content.length > 50 ? '...' : ''}</td>
                    <td>${new Date(a.created_at).toLocaleDateString()}</td>
                    <td>
                        <button class="btn btn-secondary" onclick="showAnnouncementModal(${a.id}, '${escapeHTML(a.title).replace(/'/g, "\\'")}', '${escapeHTML(a.content).replace(/'/g, "\\'")}')">Edit</button>
                        <button class="btn" style="background: var(--danger); color: white;" onclick="deleteAnnouncement(${a.id})">Delete</button>
                    </td>
                </tr>
            `).join('');
        } else {
            tbody.innerHTML = '<tr><td colspan="5" style="text-align: center;">No announcements found.</td></tr>';
        }
    } catch (e) {
        document.getElementById('announcementsTableBody').innerHTML = '<tr><td colspan="5" style="text-align: center; color: red;">Failed to load announcements.</td></tr>';
    }
}

window.showAnnouncementModal = function(id = null, title = '', content = '') {
    modalTitle.textContent = id ? 'Edit Announcement' : 'Create Announcement';
    modalBody.innerHTML = `
        <div class="form-group">
            <label>Title</label>
            <input type="text" id="annTitle" class="form-control" value="${title}" required>
        </div>
        <div class="form-group">
            <label>Content</label>
            <textarea id="annContent" class="form-control" rows="5" required>${content}</textarea>
        </div>
        <div style="display: flex; gap: 10px; justify-content: flex-end; margin-top: 1.5rem;">
            <button class="btn btn-secondary" onclick="closeModalFn()">Cancel</button>
            <button class="btn btn-primary" onclick="saveAnnouncement(${id || 'null'})">Save</button>
        </div>
    `;
    modalOverlay.classList.add('active');
}

window.saveAnnouncement = async function(id) {
    const title = document.getElementById('annTitle').value.trim();
    const content = document.getElementById('annContent').value.trim();
    
    if(!title || !content) {
        alert('Title and content are required');
        return;
    }
    
    const method = id ? 'PUT' : 'POST';
    const payload = id ? { id, title, content } : { title, content };
    
    try {
        const res = await fetch('../api/admin/manage_announcements.php', {
            method: method,
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ' + sessionStorage.getItem('govassist_token')
            },
            body: JSON.stringify(payload)
        });
        
        const text = await res.text();
        let data;
        try {
            data = JSON.parse(text);
        } catch(err) {
            console.error("Server returned non-JSON:", text);
            alert('Server error: ' + text.substring(0, 100));
            return;
        }

        if(data.success) {
            closeModalFn();
            renderAnnouncements();
        } else {
            alert(data.error || 'Failed to save announcement');
        }
    } catch (e) {
        alert('Network error: ' + e.message);
    }
}

window.deleteAnnouncement = async function(id) {
    if(!confirm('Are you sure you want to delete this announcement?')) return;
    
    try {
        const res = await fetch(`../api/admin/manage_announcements.php?id=${id}`, { 
            method: 'DELETE',
            headers: {
                'Authorization': 'Bearer ' + sessionStorage.getItem('govassist_token')
            }
        });
        const data = await res.json();
        if(data.success) {
            renderAnnouncements();
        } else {
            alert(data.error || 'Failed to delete announcement');
        }
    } catch (e) {
        alert('Network error');
    }
}

// Initialize
if (window.location.pathname.endsWith('index.html') || window.location.pathname.endsWith('/admin/')) {
    const savedView = sessionStorage.getItem('govassist_current_view') || 'dashboard';
    
    // Update active class on nav
    document.querySelectorAll('.nav-item').forEach(nav => nav.classList.remove('active'));
    const activeNav = document.querySelector(`.nav-item[data-view="${savedView}"]`);
    if(activeNav) activeNav.classList.add('active');
    
    loadView(savedView);
}
