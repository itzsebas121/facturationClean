import { Sparkles, Menu, X } from 'lucide-react';
    import './Navbar.css'
    import '../../index.css'

import { useState } from 'react';

export function Navbar() {
    const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
    return (
        <header className="fixed top-0 left-0 right-0 z-50 bg-black/80 backdrop-blur-md border-b border-white/10">
            <div className="container mx-auto px-4 py-4">
                <div className="flex justify-between items-center">
                    <div className="flex items-center gap-2">
                        <Sparkles className="h-6 w-6 text-purple-500" />
                        <span className="text-xl font-bold tracking-tight bg-clip-text text-transparent bg-gradient-to-r from-purple-500 to-cyan-400">
                            NEURALUX
                        </span>
                    </div>

                    {/* Desktop Navigation */}
                    <nav className="hidden md:flex items-center space-x-8">
                        <a href="#services" className="text-sm hover:text-purple-400 transition-colors">
                            Services
                        </a>
                        <a href="#about" className="text-sm hover:text-purple-400 transition-colors">
                            About
                        </a>
                        <a href="#team" className="text-sm hover:text-purple-400 transition-colors">
                            Team
                        </a>
                        <a href="#process" className="text-sm hover:text-purple-400 transition-colors">
                            Process
                        </a>
                        <a href="#contact" className="text-sm hover:text-purple-400 transition-colors">
                            Contact
                        </a>
                        <button className="bg-gradient-to-r from-purple-600 to-cyan-500 hover:from-purple-700 hover:to-cyan-600 text-white px-4 py-2 rounded font-semibold transition-colors">
                            Get Started
                        </button>
                    </nav>

                    {/* Mobile Menu Button */}
                    <button className="md:hidden menu-button" onClick={() => setMobileMenuOpen(!mobileMenuOpen)}>
                        {mobileMenuOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
                    </button>
                </div>
            </div>
        </header>
    );
}
