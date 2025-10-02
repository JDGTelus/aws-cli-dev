// Minimal Tailwind Configuration - Essential colors only
// Professional palette with WCAG AA compliant contrast ratios

tailwind.config = {
    theme: {
        extend: {
            colors: {
                // AWS Brand Colors
                'aws-dark': '#232f3e',
                'aws-orange': '#ff9900',
                
                // Primary Blue Scale (simplified to essential shades)
                'primary': {
                    100: '#e0effe',  // Light backgrounds
                    300: '#7cc4fd',  // Light accents
                    500: '#0c8ce9',  // Primary actions (main brand color)
                    700: '#0158a1',  // Dark accents, hover states
                    900: '#0b3f6e',  // Darkest elements
                },
                
                // Simplified Neutrals (grays)
                'neutral': {
                    50: '#f8fafc',   // Page backgrounds
                    100: '#f1f5f9',  // Card backgrounds
                    200: '#e2e8f0',  // Borders
                    400: '#94a3b8',  // Placeholder text
                    600: '#475569',  // Body text (WCAG AA on white)
                    700: '#334155',  // Headings (WCAG AAA on white)
                    800: '#1e293b',  // Dark text
                },
                
                // Semantic Colors (status indicators)
                'success': '#10b981',
                'warning': '#f59e0b',
                'error': '#ef4444',
                'info': '#0c8ce9',
            },
        }
    }
}
