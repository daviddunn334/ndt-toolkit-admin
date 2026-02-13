# Custom Domain Setup Guide - ndt-toolkit.com

## 🎯 Goal
Connect your verified domain **ndt-toolkit.com** to three Firebase hosting sites:
- **ndt-toolkit.com** → Production site (main branch)
- **preview.ndt-toolkit.com** → Preview site (development branch)
- **admin.ndt-toolkit.com** → Admin site (admin-panel branch)

---

## 📋 Prerequisites
- ✅ Domain **ndt-toolkit.com** is verified in Firebase
- ✅ Three Firebase hosting sites created:
  - `ndt-toolkit` (production)
  - `ndt-toolkit-preview` (preview)
  - `admin-ndt-toolkit` (admin)

---

## 🚀 Step-by-Step Instructions

### Step 1: Connect Main Domain to Production Site

1. **Open Firebase Console:**
   - Go to https://console.firebase.google.com/project/ndt-toolkit/hosting/sites
   - Find the **ndt-toolkit** site (production)
   - Click **"Add custom domain"**

2. **Enter Domain:**
   - Type: `ndt-toolkit.com`
   - Click **"Continue"**

3. **Choose Domain Type:**
   - Select: **"Redirect ndt-toolkit.com to an existing website"**
   - Or select: **"Add both www.ndt-toolkit.com and ndt-toolkit.com"** (recommended)
   - Click **"Continue"**

4. **Configure DNS Records:**
   Firebase will show you DNS records to add. They'll look like this:
   ```
   Type: A
   Name: @ (or blank/ndt-toolkit.com)
   Value: IP addresses provided by Firebase
   
   Type: A
   Name: www
   Value: IP addresses provided by Firebase
   ```

5. **Add DNS Records to Your Domain Registrar:**
   - Go to your domain registrar (GoDaddy, Namecheap, etc.)
   - Find DNS management / DNS settings
   - Add the A records exactly as Firebase shows
   - **Save changes**

6. **Verify in Firebase:**
   - Click **"Verify"** in Firebase Console
   - Wait for DNS propagation (can take 5 minutes to 24 hours)
   - Firebase will automatically provision SSL certificate

---

### Step 2: Connect Preview Subdomain to Preview Site

1. **Open Firebase Console:**
   - Go to https://console.firebase.google.com/project/ndt-toolkit/hosting/sites
   - Find the **ndt-toolkit-preview** site
   - Click **"Add custom domain"**

2. **Enter Subdomain:**
   - Type: `preview.ndt-toolkit.com`
   - Click **"Continue"**

3. **Configure DNS Record:**
   Firebase will provide a TXT record for verification and an A record:
   ```
   Type: TXT (for verification)
   Name: _acme-challenge.preview
   Value: (provided by Firebase)
   
   Type: A
   Name: preview
   Value: IP addresses provided by Firebase
   ```

4. **Add DNS Records:**
   - Go to your domain registrar's DNS settings
   - Add both the TXT record (for verification) and A record
   - **Save changes**

5. **Verify in Firebase:**
   - Click **"Verify"** in Firebase Console
   - Wait for propagation
   - SSL certificate will be auto-provisioned

---

### Step 3: Connect Admin Subdomain to Admin Site

1. **Open Firebase Console:**
   - Go to https://console.firebase.google.com/project/ndt-toolkit/hosting/sites
   - Find the **admin-ndt-toolkit** site
   - Click **"Add custom domain"**

2. **Enter Subdomain:**
   - Type: `admin.ndt-toolkit.com`
   - Click **"Continue"**

3. **Configure DNS Record:**
   Firebase will provide records similar to preview:
   ```
   Type: TXT (for verification)
   Name: _acme-challenge.admin
   Value: (provided by Firebase)
   
   Type: A
   Name: admin
   Value: IP addresses provided by Firebase
   ```

4. **Add DNS Records:**
   - Go to your domain registrar's DNS settings
   - Add both the TXT record and A record
   - **Save changes**

5. **Verify in Firebase:**
   - Click **"Verify"** in Firebase Console
   - Wait for propagation
   - SSL certificate will be auto-provisioned

---

## ✅ Verification Checklist

After completing all steps, verify each domain:

- [ ] **ndt-toolkit.com** loads the production app
- [ ] **www.ndt-toolkit.com** loads the production app (or redirects)
- [ ] **preview.ndt-toolkit.com** loads the preview app
- [ ] **admin.ndt-toolkit.com** loads the admin panel (when ready)
- [ ] All domains use HTTPS (SSL certificates active)
- [ ] No SSL warnings in browser

---

## 🔍 DNS Configuration Summary

After completing all steps, your DNS records should look like this:

| Type | Name/Host | Value | Purpose |
|------|-----------|-------|---------|
| A | @ | Firebase IPs | Main domain |
| A | www | Firebase IPs | WWW subdomain |
| A | preview | Firebase IPs | Preview subdomain |
| A | admin | Firebase IPs | Admin subdomain |
| TXT | _acme-challenge.preview | Firebase value | SSL verification |
| TXT | _acme-challenge.admin | Firebase value | SSL verification |

---

## ⏰ Expected Timeline

- **DNS propagation:** 5 minutes to 24 hours (typically 15-30 minutes)
- **SSL certificate provisioning:** Automatic after DNS verification
- **Full activation:** Usually within 1 hour after DNS propagation

---

## 🧪 Testing Your Domains

Test each domain after setup:

```bash
# Test main domain
curl -I https://ndt-toolkit.com

# Test preview subdomain
curl -I https://preview.ndt-toolkit.com

# Test admin subdomain
curl -I https://admin.ndt-toolkit.com
```

All should return **200 OK** or **301/302 redirects** (not 404 or errors).

---

## 🆘 Troubleshooting

### Domain Not Loading
- **Wait longer:** DNS can take up to 24 hours
- **Clear browser cache:** Try incognito mode
- **Check DNS propagation:** Use https://dnschecker.org

### SSL Certificate Not Working
- Wait for Firebase to provision (can take 1 hour after DNS verification)
- Verify TXT records are correct
- Try re-verifying in Firebase Console

### Wrong Site Loading
- Verify you connected the subdomain to the correct Firebase hosting site
- Check `.firebaserc` targets match site IDs

---

## 📱 Next Steps After Domain Setup

Once all domains are connected and working:

1. ✅ **Production domain** (ndt-toolkit.com) is live
2. ✅ **Preview domain** (preview.ndt-toolkit.com) ready for testing
3. 🔜 **Admin domain** (admin.ndt-toolkit.com) ready for admin panel
4. 🔜 Build admin panel branch
5. 🔜 Clean up main branch (remove admin code)

---

## 📞 Need Help?

- Firebase Domain Connection: https://firebase.google.com/docs/hosting/custom-domain
- DNS Support: Contact your domain registrar
- Check status in Firebase Console: https://console.firebase.google.com/project/ndt-toolkit/hosting/sites

---

**Start with Step 1 (main domain) and work through each step sequentially. Let me know when you've completed each section!**
