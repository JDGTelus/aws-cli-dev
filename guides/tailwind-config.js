// Minimal Tailwind Configuration - Using default colors only
// No custom colors - leveraging Tailwind's built-in palette with transparency

tailwind.config = {
    theme: {
        extend: {
            // No custom colors - using Tailwind defaults:
            // - blue-* for primary elements
            // - slate-* for neutrals
            // - Transparency with /50, /75, /90, /95 for depth
        }
    }
}
