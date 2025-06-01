"use client";

import { Bot, Menu } from "lucide-react";
import { motion } from "framer-motion";
import { useNavigate } from "react-router-dom";
import React from "react";
import './Navbar.module.css'

export default function Navbar() {
    const navigate = useNavigate();
    return (
        <motion.nav
            initial={{ y: -100 }}
            animate={{ y: 0 }}
            className={styles.navbar}
        >
            <Link href="/" className={styles.logo}>
                <Bot className={styles.logoIcon} />
                <span className={styles.logoText}>ResearchAI</span>
            </Link>

            <div className={styles.navLinks}>
                <NavLink href="/features">Features</NavLink>
                <NavLink href="/how-it-works">How it Works</NavLink>
                <NavLink href="/examples">Examples</NavLink>
                <NavLink href="/pricing">Pricing</NavLink>
            </div>

            <div className={styles.authButtons}>
                <Button variant="ghost" className={styles.signInButton}>
                    Sign In
                </Button>
                <Button className={styles.getStartedButton}>Get Started</Button>
            </div>

            <Button variant="ghost" size="icon" className={styles.mobileMenuButton}>
                <Menu className="w-6 h-6" />
            </Button>
        </motion.nav>
    );
}

function NavLink({
    href,
    children,
}: {
    href: string;
    children: React.ReactNode;
}) {
    return (
        <Link href={href} className={`${styles.navLink} group`}>
            {children}
            <span className={styles.navLinkUnderline} />
        </Link>
    );
}
