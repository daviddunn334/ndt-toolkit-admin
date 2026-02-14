# 🚀 NDT-ToolKit Marketing Website - Implementation Plan

## 📋 Project Overview

**Goal:** Build a premium, high-tech SaaS marketing website for NDT-ToolKit that matches the app's dark, professional aesthetic and drives user acquisition.

**NOT the app itself** - this is a landing/marketing site to showcase features and convert visitors to app users.

---

## 🎯 Core Objectives

1. **Showcase Professional Tools:** Highlight PAUT/UT calculators and field productivity features
2. **Establish Credibility:** Position as engineering-grade software for inspection professionals
3. **Drive Conversions:** Clear CTAs for app download and login
4. **Match Brand Identity:** Dark, modern, high-tech aesthetic consistent with the app
5. **Performance First:** Fast, responsive, mobile-optimized experience

---

## 🛠️ Tech Stack

### Core Framework
- **Next.js 14+** (App Router)
- **TypeScript** (strict mode)
- **React 18+**

### Styling & UI
- **Tailwind CSS** (utility-first)
- **DaisyUI** (custom theme configuration)
- **Framer Motion** (subtle animations only)

### Deployment
- **Vercel** (recommended for Next.js)
- **Alternative:** Firebase Hosting (to match your app's hosting)

### Additional Tools
- **next/image** (optimized images)
- **next/font** (Google Fonts)
- **react-icons** (icon library)
- **Lucide React** (modern icon set)

---

## 🎨 Design System (Match App Theme)

### Color Palette
Based on your app's `AppTheme` class:

```typescript
// tailwind.config.ts
const colors = {
  // Backgrounds
  'ndt-background': '#1E232A',      // Main background
  'ndt-surface': '#2A313B',         // Card/panel surface
  'ndt-elevated': '#242A33',        // Slightly elevated
  
  // Text
  'ndt-text-primary': '#EDF9FF',    // Primary text
  'ndt-text-secondary': '#AEBBC8',  // Secondary text
  'ndt-text-muted': '#7F8A96',      // Muted text
  
  // Accents
  'ndt-purple': '#6C5BFF',          // Primary accent (buttons, links)
  'ndt-green': '#00E5A8',           // Success/highlights
  'ndt-pink': '#FE637E',            // Secondary accent
  'ndt-yellow': '#F8B800',          // Warnings/emphasis
  'ndt-teal': '#2A9D8F',            // Info/alternative accent
}
```

### DaisyUI Theme Configuration

```typescript
// tailwind.config.ts - DaisyUI theme
themes: [
  {
    ndtDark: {
      "primary": "#6C5BFF",        // Purple
      "secondary": "#FE637E",      // Pink
      "accent": "#00E5A8",         // Green/Teal
      "neutral": "#1E232A",        // Background
      "base-100": "#2A313B",       // Surface
      "base-200": "#242A33",       // Elevated
      "base-300": "#1E232A",       // Background
      "info": "#2A9D8F",           // Teal
      "success": "#00E5A8",        // Green
      "warning": "#F8B800",        // Yellow
      "error": "#FE637E",          // Pink/Red
    }
  }
]
```

### Typography
- **Headlines:** Bold, modern, high contrast
- **Body:** Clean, readable (16px base)
- **Technical Text:** Monospace for code/technical specs
- **Font:** Inter or Manrope for professional look

### Visual Effects
- ✅ Subtle gradients on hero sections
- ✅ Soft glow on hover (purple/teal)
- ✅ Glass-morphism cards (backdrop blur)
- ✅ Minimal shadows (dark theme appropriate)
- ✅ Rounded corners (12px-24px)
- ❌ NO excessive animations
- ❌ NO parallax scrolling
- ❌ NO auto-playing videos

---

## 📱 Site Structure

### Page: Home (/) - Landing Page

#### Section 1: Hero
**Purpose:** Immediate impact, clear value proposition

**Layout:**
```
┌─────────────────────────────────────────┐
│         [Animated beam-line bg]         │
│                                          │
│   Professional NDT Tools. Reimagined.   │  ← H1, 48-64px
│                                          │
│   Advanced UT, PAUT, MT, and field      │  ← Subtitle
│   productivity tools — all in one       │
│   powerful app.                         │
│                                          │
│   [Download App]  [View Features]       │  ← CTAs
│                                          │
│   [Hero visual: Beam plot mockup]       │  ← Optional
└─────────────────────────────────────────┘
```

**Elements:**
- Large bold headline with gradient text effect
- Clear subtitle (2 lines max)
- Two primary CTAs (download + explore)
- Subtle animated background (beam lines, grid, or gradient)
- Optional: Mockup of beam plot calculator

**Animations:**
- Fade in on load
- Subtle floating animation on mockup
- Beam line pulse effect (if used)

---

#### Section 2: Problem/Solution (Optional)
**Purpose:** Establish pain points and position app as solution

**Layout:**
```
┌─────────────────────────────────────────┐
│   Built for Pipeline Integrity          │  ← H2
│   Professionals                          │
│                                          │
│   [Pain point 1]  [Pain point 2]        │  ← Cards
│   Manual calc     No field tools        │
│                                          │
│   ↓                                      │
│                                          │
│   One powerful app with everything       │
│   you need in the field.                │
└─────────────────────────────────────────┘
```

---

#### Section 3: Features Grid
**Purpose:** Showcase all major features

**Layout:** 3-column grid (responsive: 1 col mobile, 2 col tablet, 3 col desktop)

**Feature Cards (9 total):**

1. **Dynamic Beam Plot Visualizer**
   - Icon: 📡 or beam icon
   - Description: "Real-time UT beam visualization with angle, depth, and skip calculations"
   
2. **Steering & Sweep Simulator**
   - Icon: ↔️ or array icon
   - Description: "PAUT array steering simulation with element-level beam forming"
   
3. **Grating Lobe Predictor**
   - Icon: ⚠️ or wave icon
   - Description: "Calculate and visualize grating lobe formation in phased arrays"
   
4. **Resolution vs Aperture**
   - Icon: 📊 or graph icon
   - Description: "Interactive graphs showing aperture impact on resolution"
   
5. **Coordinate Logger**
   - Icon: 📍 or GPS icon
   - Description: "Offline GPS coordinate logging with dig organization"
   
6. **Photo Logger**
   - Icon: 📷 or camera icon
   - Description: "Capture and organize field photos with metadata"
   
7. **Time Tracker**
   - Icon: ⏱️ or clock icon
   - Description: "Track time per dig, job, or inspection task"
   
8. **Code Workflow Guides**
   - Icon: 📋 or checklist icon
   - Description: "Step-by-step workflows for ASME, API, and CSA codes"
   
9. **Weld Inspection Flowcharts**
   - Icon: 🔗 or flow icon
   - Description: "Decision trees for weld acceptance and rejection criteria"

**Card Design:**
```css
- Background: glass-morphism (backdrop-blur)
- Border: 1px solid rgba(255,255,255,0.05)
- Padding: 24px
- Border radius: 16px
- Hover: glow effect (purple or teal)
- Icon: 48px, colored with accent
- Title: 20px, bold
- Description: 14px, muted text
```

---

#### Section 4: High-Tech Visualization
**Purpose:** Show actual app interface (mockups or screenshots)

**Layout:**
```
┌─────────────────────────────────────────┐
│   See It In Action                       │  ← H2
│                                          │
│   ┌─────────┐  ┌─────────┐  ┌─────────┐ │
│   │ Beam    │  │ Array   │  │ Field   │ │  ← Mockups
│   │ Plot    │  │ Calc    │  │ Logger  │ │
│   └─────────┘  └─────────┘  └─────────┘ │
│                                          │
│   Real engineering calculations.         │
│   Field-tested workflows.                │
└─────────────────────────────────────────┘
```

**Elements:**
- 3 large mockup images or videos (looping)
- Subtle gradient background
- Optional: bento-grid layout for multiple smaller mockups
- Captions under each mockup

---

#### Section 5: Field Productivity
**Purpose:** Highlight offline-first and field tools

**Layout:** Split screen (image left, content right)

```
┌─────────────────────────────────────────┐
│  [Mockup]    │  Built for the Field     │
│   Photo      │                           │
│   Logger     │  ✓ Offline-first design  │
│   Screenshot │  ✓ GPS coordinate logging│
│              │  ✓ Photo organization    │
│              │  ✓ Time tracking         │
│              │  ✓ Dig management        │
│              │                           │
│              │  [Learn More →]          │
└─────────────────────────────────────────┘
```

**Features List:**
- ✓ Offline-first (works without internet)
- ✓ GPS coordinate logging with accuracy tracking
- ✓ Photo capture with automatic metadata
- ✓ Time tracking per dig/job
- ✓ Organize by project, client, dig number
- ✓ Export to Excel/PDF

---

#### Section 6: Professional Credibility
**Purpose:** Build trust with engineering professionals

**Layout:** Centered content with stats/badges

```
┌─────────────────────────────────────────┐
│   Trusted by Pipeline Integrity         │  ← H2
│   Professionals                          │
│                                          │
│   ┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐   │
│   │500+ │  │ASME │  │ API │  │ CSA │   │  ← Stats/Badges
│   │Users│  │Based│  │Code │  │ z662│   │
│   └─────┘  └─────┘  └─────┘  └─────┘   │
│                                          │
│   "Real calculations. Engineering-based │
│    models. Field-tested workflows."     │
└─────────────────────────────────────────┘
```

**Trust Elements:**
- User count (if available)
- Code standards referenced (ASME, API, CSA)
- "Engineering-grade" badge
- Optional: Testimonials (if available)

---

#### Section 7: Call-to-Action
**Purpose:** Final conversion push

**Layout:** Large, centered, glowing

```
┌─────────────────────────────────────────┐
│                                          │
│        Get NDT-ToolKit                   │  ← Large H2
│                                          │
│    Professional NDT tools at your        │
│    fingertips.                           │
│                                          │
│   [🍎 Download on App Store]            │  ← Buttons
│   [📱 Get it on Google Play]            │
│                                          │
│   Or [Sign In →] if you already have    │
│   an account.                            │
│                                          │
└─────────────────────────────────────────┘
```

**Elements:**
- Large glowing gradient background
- Two primary buttons (App Store, Google Play)
- Secondary link to web login
- Optional: Email signup for updates

---

#### Section 8: Footer
**Purpose:** Legal, contact, navigation

**Layout:** Minimal, dark

```
┌─────────────────────────────────────────┐
│  NDT-ToolKit                             │
│                                          │
│  Features | About | Contact | Privacy   │
│                                          │
│  contact@ndt-toolkit.com                │
│                                          │
│  © 2026 NDT-ToolKit. All rights reserved.│
└─────────────────────────────────────────┘
```

---

## 🎬 Animations & Interactions

### Subtle Only (No Overload)

**Hero Section:**
- Fade in headline (0.5s delay)
- Fade in subtitle (0.7s delay)
- Fade in CTAs (0.9s delay)
- Subtle floating animation on mockup (optional)

**Feature Cards:**
- Fade up on scroll (intersection observer)
- Glow on hover (0.3s transition)
- Scale up slightly on hover (1.02x)

**Mockups:**
- Parallax scroll (subtle, 0.1x speed difference)
- Fade in on scroll

**Buttons:**
- Glow effect on hover
- Scale on click (0.95x)
- Smooth color transition

**Background:**
- Animated beam lines or gradient (very subtle)
- Grid lines with slow pulse

**NO:**
- ❌ Auto-playing videos
- ❌ Complex parallax
- ❌ Excessive scrolljacking
- ❌ Pop-ups or modals on load

---

## 📐 Component Structure

### File Organization

```
marketing-site/
├── app/
│   ├── layout.tsx              # Root layout
│   ├── page.tsx                # Home page
│   ├── globals.css             # Global styles
│   └── fonts/                  # Local fonts
├── components/
│   ├── Hero.tsx                # Hero section
│   ├── FeaturesGrid.tsx        # Feature cards
│   ├── FeatureCard.tsx         # Individual feature card
│   ├── Visualization.tsx       # Mockup section
│   ├── FieldProductivity.tsx   # Field tools section
│   ├── Credibility.tsx         # Trust section
│   ├── CTA.tsx                 # Call-to-action
│   ├── Footer.tsx              # Footer
│   └── ui/                     # Reusable UI components
│       ├── Button.tsx
│       ├── Card.tsx
│       ├── GlowButton.tsx
│       └── SectionContainer.tsx
├── lib/
│   └── constants.ts            # Feature data, colors
├── public/
│   ├── images/                 # Mockups, icons
│   └── favicon.ico
├── styles/
│   └── animations.css          # Framer Motion variants
├── tailwind.config.ts          # Tailwind + DaisyUI config
├── tsconfig.json
└── package.json
```

---

## 🎨 Theme Configuration

### tailwind.config.ts

```typescript
import type { Config } from 'tailwindcss'
import daisyui from 'daisyui'

const config: Config = {
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        'ndt-background': '#1E232A',
        'ndt-surface': '#2A313B',
        'ndt-elevated': '#242A33',
        'ndt-text-primary': '#EDF9FF',
        'ndt-text-secondary': '#AEBBC8',
        'ndt-text-muted': '#7F8A96',
        'ndt-purple': '#6C5BFF',
        'ndt-green': '#00E5A8',
        'ndt-pink': '#FE637E',
        'ndt-yellow': '#F8B800',
        'ndt-teal': '#2A9D8F',
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        mono: ['Fira Code', 'monospace'],
      },
      boxShadow: {
        'glow-purple': '0 0 20px rgba(108, 91, 255, 0.3)',
        'glow-teal': '0 0 20px rgba(0, 229, 168, 0.3)',
        'glow-pink': '0 0 20px rgba(254, 99, 126, 0.3)',
      },
      backgroundImage: {
        'gradient-radial': 'radial-gradient(var(--tw-gradient-stops))',
      },
    },
  },
  plugins: [daisyui],
  daisyui: {
    themes: [
      {
        ndtDark: {
          "primary": "#6C5BFF",
          "secondary": "#FE637E",
          "accent": "#00E5A8",
          "neutral": "#1E232A",
          "base-100": "#2A313B",
          "base-200": "#242A33",
          "base-300": "#1E232A",
          "info": "#2A9D8F",
          "success": "#00E5A8",
          "warning": "#F8B800",
          "error": "#FE637E",
        }
      }
    ],
  },
}

export default config
```

---

## 🧩 Component Examples

### Hero.tsx

```typescript
'use client'
import { motion } from 'framer-motion'
import { GlowButton } from './ui/GlowButton'

export function Hero() {
  return (
    <section className="relative min-h-screen flex items-center justify-center overflow-hidden bg-ndt-background">
      {/* Animated background */}
      <div className="absolute inset-0 opacity-20">
        {/* Grid or beam line animation */}
      </div>
      
      <div className="container mx-auto px-4 text-center z-10">
        <motion.h1
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          className="text-5xl md:text-7xl font-bold mb-6"
        >
          <span className="bg-gradient-to-r from-ndt-purple to-ndt-green bg-clip-text text-transparent">
            Professional NDT Tools.
          </span>
          <br />
          Reimagined.
        </motion.h1>
        
        <motion.p
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.5 }}
          className="text-xl md:text-2xl text-ndt-text-secondary mb-12 max-w-3xl mx-auto"
        >
          Advanced UT, PAUT, MT, and field productivity tools — all in one powerful app.
        </motion.p>
        
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.7 }}
          className="flex flex-col sm:flex-row gap-4 justify-center"
        >
          <GlowButton variant="primary" size="lg">
            Download App
          </GlowButton>
          <GlowButton variant="secondary" size="lg">
            View Features
          </GlowButton>
        </motion.div>
      </div>
    </section>
  )
}
```

### FeatureCard.tsx

```typescript
'use client'
import { motion } from 'framer-motion'
import { LucideIcon } from 'lucide-react'

interface FeatureCardProps {
  icon: LucideIcon
  title: string
  description: string
  color: 'purple' | 'green' | 'pink' | 'teal'
}

export function FeatureCard({ icon: Icon, title, description, color }: FeatureCardProps) {
  const colorClasses = {
    purple: 'hover:shadow-glow-purple',
    green: 'hover:shadow-glow-teal',
    pink: 'hover:shadow-glow-pink',
    teal: 'hover:shadow-glow-teal',
  }
  
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true }}
      whileHover={{ scale: 1.02 }}
      className={`
        p-6 rounded-2xl backdrop-blur-md
        bg-ndt-surface/50 border border-white/5
        transition-all duration-300
        ${colorClasses[color]}
      `}
    >
      <Icon className="w-12 h-12 mb-4 text-ndt-purple" />
      <h3 className="text-xl font-bold text-ndt-text-primary mb-2">
        {title}
      </h3>
      <p className="text-ndt-text-secondary">
        {description}
      </p>
    </motion.div>
  )
}
```

---

## 📊 Feature Data Structure

### lib/constants.ts

```typescript
import { Calculator, Radio, AlertTriangle, BarChart, MapPin, Camera, Clock, FileText, GitBranch } from 'lucide-react'

export const features = [
  {
    icon: Calculator,
    title: 'Dynamic Beam Plot Visualizer',
    description: 'Real-time UT beam visualization with angle, depth, and skip calculations',
    color: 'purple' as const,
  },
  {
    icon: Radio,
    title: 'Steering & Sweep Simulator',
    description: 'PAUT array steering simulation with element-level beam forming',
    color: 'green' as const,
  },
  {
    icon: AlertTriangle,
    title: 'Grating Lobe Predictor',
    description: 'Calculate and visualize grating lobe formation in phased arrays',
    color: 'pink' as const,
  },
  {
    icon: BarChart,
    title: 'Resolution vs Aperture',
    description: 'Interactive graphs showing aperture impact on resolution',
    color: 'teal' as const,
  },
  {
    icon: MapPin,
    title: 'Coordinate Logger',
    description: 'Offline GPS coordinate logging with dig organization',
    color: 'purple' as const,
  },
  {
    icon: Camera,
    title: 'Photo Logger',
    description: 'Capture and organize field photos with metadata',
    color: 'green' as const,
  },
  {
    icon: Clock,
    title: 'Time Tracker',
    description: 'Track time per dig, job, or inspection task',
    color: 'pink' as const,
  },
  {
    icon: FileText,
    title: 'Code Workflow Guides',
    description: 'Step-by-step workflows for ASME, API, and CSA codes',
    color: 'teal' as const,
  },
  {
    icon: GitBranch,
    title: 'Weld Inspection Flowcharts',
    description: 'Decision trees for weld acceptance and rejection criteria',
    color: 'purple' as const,
  },
]
```

---

## 🔍 SEO Configuration

### app/layout.tsx - Metadata

```typescript
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'NDT-ToolKit | Professional UT & PAUT Calculators for Pipeline Inspection',
  description: 'Advanced ultrasonic testing tools for pipeline integrity professionals. PAUT beam simulators, field productivity tools, and code workflows in one powerful app.',
  keywords: [
    'NDT tools',
    'ultrasonic testing',
    'PAUT',
    'phased array',
    'pipeline inspection',
    'UT calculator',
    'beam plot',
    'field inspection tools',
    'ASME inspection',
    'API inspection',
  ],
  authors: [{ name: 'NDT-ToolKit' }],
  creator: 'NDT-ToolKit',
  openGraph: {
    type: 'website',
    locale: 'en_US',
    url: 'https://ndt-toolkit.com',
    title: 'NDT-ToolKit - Professional NDT Tools',
    description: 'Advanced UT, PAUT, and field productivity tools for pipeline inspection professionals.',
    siteName: 'NDT-ToolKit',
    images: [
      {
        url: '/og-image.png',
        width: 1200,
        height: 630,
        alt: 'NDT-ToolKit Preview',
      },
    ],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'NDT-ToolKit - Professional NDT Tools',
    description: 'Advanced UT, PAUT, and field productivity tools.',
    images: ['/og-image.png'],
  },
  robots: {
    index: true,
    follow: true,
  },
}
```

---

## ⚡ Performance Optimization

### Image Optimization
```typescript
import Image from 'next/image'

// Use Next.js Image component
<Image
  src="/mockups/beam-plot.png"
  alt="Beam Plot Calculator"
  width={800}
  height={600}
  quality={90}
  priority // For above-fold images
  placeholder="blur"
  blurDataURL="data:image/..." // Low-res placeholder
/>
```

### Code Splitting
```typescript
// Lazy load heavy components
import dynamic from 'next/dynamic'

const Visualization = dynamic(() => import('@/components/Visualization'), {
  loading: () => <div>Loading...</div>,
  ssr: false, // If client-only
})
```

### Font Optimization
```typescript
// app/layout.tsx
import { Inter } from 'next/font/google'

const inter = Inter({
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-inter',
})
```

---

## 📱 Responsive Design Breakpoints

```css
/* Mobile First Approach */

/* Mobile: 0-639px (default) */
.feature-grid {
  grid-template-columns: 1fr;
}

/* Tablet: 640px+ */
@media (min-width: 640px) {
  .feature-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

/* Desktop: 1024px+ */
@media (min-width: 1024px) {
  .feature-grid {
    grid-template-columns: repeat(3, 1fr);
  }
}

/* Large Desktop: 1536px+ */
@media (min-width: 1536px) {
  .container {
    max-width: 1280px;
  }
}
```

---

## 🚀 Deployment Strategy

### Option 1: Vercel (Recommended)
```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel --prod

# Custom domain
vercel domains add ndt-toolkit.com
```

**Benefits:**
- Automatic HTTPS
- Edge network (fast globally)
- Zero config
- Preview deployments
- Built for Next.js

### Option 2: Firebase Hosting
```bash
# Build
npm run build

# Deploy
firebase deploy --only hosting

# Custom domain
firebase hosting:channel:deploy production
```

**Benefits:**
- Matches your app hosting
- Same Firebase project
- Unified billing

### Environment Variables
```env
# .env.local
NEXT_PUBLIC_APP_URL=https://app.ndt-toolkit.com
NEXT_PUBLIC_DOWNLOAD_IOS=https://apps.apple.com/...
NEXT_PUBLIC_DOWNLOAD_ANDROID=https://play.google.com/...
NEXT_PUBLIC_ANALYTICS_ID=G-XXXXXXXXXX
```

---

## 📋 Implementation Checklist

### Phase 1: Setup (Day 1)
- [ ] Initialize Next.js project with TypeScript
- [ ] Install dependencies (Tailwind, DaisyUI, Framer Motion)
- [ ] Configure tailwind.config.ts with NDT theme
- [ ] Set up folder structure
- [ ] Configure fonts (Inter or Manrope)
- [ ] Create base layout and global styles

### Phase 2: Components (Day 2-3)
- [ ] Build Hero section
- [ ] Create FeatureCard component
- [ ] Build FeaturesGrid section
- [ ] Create GlowButton component
- [ ] Build Visualization section (mockups)
- [ ] Create FieldProductivity section
- [ ] Build Credibility section
- [ ] Create CTA section
- [ ] Build Footer component

### Phase 3: Content & Polish (Day 4)
- [ ] Add feature data to constants
- [ ] Implement animations (Framer Motion)
- [ ] Add background effects (grid, gradient)
- [ ] Create placeholder mockup images
- [ ] Test responsive design
- [ ] Optimize images with Next/Image

### Phase 4: SEO & Deploy (Day 5)
- [ ] Add metadata and OpenGraph tags
- [ ] Create og-image.png (1200x630)
- [ ] Add favicon and app icons
- [ ] Test performance (Lighthouse)
- [ ] Deploy to Vercel/Firebase
- [ ] Set up custom domain
- [ ] Add analytics (Google Analytics or Plausible)

---

## 📈 Success Metrics

### Performance Goals
- **Lighthouse Score:** 95+ on all metrics
- **First Contentful Paint:** < 1.5s
- **Time to Interactive:** < 3s
- **Cumulative Layout Shift:** < 0.1

### User Engagement
- **Bounce Rate:** < 50%
- **Time on Site:** > 2 minutes
- **CTA Click Rate:** > 10%
- **Mobile Traffic:** Support 60%+ mobile users

---

## 🎯 Key Success Factors

### ✅ DO
- Match app's dark theme exactly
- Keep animations subtle and professional
- Focus on engineering credibility
- Mobile-first responsive design
- Fast loading (<3s interactive)
- Clear CTAs throughout
- High-quality mockups/screenshots

### ❌ DON'T
- Overly corporate/generic design
- Excessive animations or effects
- Cluttered layout
- Cheesy marketing copy
- Slow loading images
- Auto-play videos
- Pop-ups or modals

---

## 📞 Call to Action Strategy

### Primary CTAs (Top Priority)
1. **Download App** (Hero, sticky header, footer)
2. **View Features** (Hero)
3. **Get Started** (Final CTA section)

### Secondary CTAs
1. **Sign In** (Header, CTA section)
2. **Learn More** (Feature sections)
3. **Contact** (Footer)

### Button Hierarchy
- **Primary:** Purple glow button (download/signup)
- **Secondary:** Outlined button (explore/learn)
- **Tertiary:** Text link (sign in/contact)

---

## 🎨 Visual Reference

Your marketing site should feel like:
- **Stripe** (clean, modern, professional)
- **Vercel** (dark mode, technical)
- **Linear** (smooth animations, glass UI)
- **GitHub Dark** (developer-focused)

**NOT like:**
- Generic corporate sites
- Overly colorful SaaS
- Cluttered feature dumps
- Cheesy stock photo sites

---

## 📦 Deliverables

### Code
- [ ] Complete Next.js project
- [ ] Tailwind + DaisyUI configured
- [ ] All sections implemented
- [ ] Responsive design
- [ ] Framer Motion animations
- [ ] SEO optimized
- [ ] Production ready

### Assets
- [ ] Logo files (SVG, PNG)
- [ ] App mockups (high-res)
- [ ] OG image (1200x630)
- [ ] Favicon set
- [ ] Icon library configured

### Documentation
- [ ] README with setup instructions
- [ ] Deployment guide
- [ ] Content update guide
- [ ] Analytics setup

---

## 💰 Estimated Timeline

**Total:** 5-7 days for full implementation

- **Day 1:** Setup + Theme + Layout
- **Day 2:** Hero + Features sections
- **Day 3:** Mockups + CTA + Footer
- **Day 4:** Animations + Polish + Testing
- **Day 5:** SEO + Deploy + Domain setup

---

## 🔗 Quick Start Command

```bash
# Create Next.js project
npx create-next-app@latest ndt-toolkit-marketing \
  --typescript \
  --tailwind \
  --app \
  --no-src-dir

cd ndt-toolkit-marketing

# Install dependencies
npm install daisyui framer-motion lucide-react

# Start dev server
npm run dev
```

---

**Ready to build a professional, high-tech marketing site that converts visitors into users!** 🚀

This plan ensures your marketing website matches your app's premium dark aesthetic while driving user acquisition through clear value propositions and professional presentation.
