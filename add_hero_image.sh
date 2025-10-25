#!/bin/bash
# Script to add the Times Square hero image to your Rails app

echo "🎯 Adding Beautiful Times Square Image to Orillia Malayalee Association Website"
echo "=================================================================="

# Check if we're in the right directory
if [ ! -f "Gemfile" ] || [ ! -d "app" ]; then
    echo "❌ Error: Please run this script from your Rails project root directory"
    exit 1
fi

# Create assets/images directory if it doesn't exist
mkdir -p app/assets/images

echo "📁 Assets directory ready: app/assets/images/"

# Instructions for adding the image
echo ""
echo "📸 TO ADD YOUR TIMES SQUARE IMAGE:"
echo "1. Save your Times Square photo as 'community-hero.jpg'"
echo "2. Copy it to: app/assets/images/community-hero.jpg"
echo "3. Or drag and drop it into the app/assets/images/ folder"
echo ""

# Check if image already exists
if [ -f "app/assets/images/community-hero.jpg" ]; then
    echo "✅ Image found! Your hero image is ready."
    
    # Get image size if possible
    if command -v identify &> /dev/null; then
        echo "📏 Image details:"
        identify app/assets/images/community-hero.jpg
    fi
else
    echo "⏳ Waiting for image... Please add your Times Square photo as:"
    echo "   📍 app/assets/images/community-hero.jpg"
    echo ""
    echo "💡 The image will appear in a beautiful hero section with:"
    echo "   ✨ Rounded corners and shadow effects"
    echo "   🎨 Gradient border animation"
    echo "   📱 Responsive design"
    echo "   🖼️  Professional layout alongside your title"
fi

echo ""
echo "🚀 Once the image is added, restart your Rails server:"
echo "   rails server"
echo ""
echo "🌐 Then visit: http://localhost:3000"
echo "=================================================================="