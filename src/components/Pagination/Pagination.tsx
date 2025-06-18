"use client"

import { ChevronLeft, ChevronRight, ChevronsLeft, ChevronsRight } from "lucide-react"
import "./Pagination.css"

interface PaginationProps {
  currentPage: number
  totalPages: number
  onPageChange: (page: number) => void
}

export function Pagination({ currentPage, totalPages, onPageChange }: PaginationProps) {
  const getVisiblePages = () => {
    const delta = 2
    const range = []
    const rangeWithDots = []

    if (totalPages <= 1) return [1]

    for (let i = Math.max(2, currentPage - delta); i <= Math.min(totalPages - 1, currentPage + delta); i++) {
      range.push(i)
    }

    if (currentPage - delta > 2) {
      rangeWithDots.push(1, "...")
    } else {
      rangeWithDots.push(1)
    }

    rangeWithDots.push(...range)

    if (currentPage + delta < totalPages - 1) {
      rangeWithDots.push("...", totalPages)
    } else if (totalPages > 1) {
      rangeWithDots.push(totalPages)
    }

    return rangeWithDots
  }

  const visiblePages = getVisiblePages()
  const handlePrevious = () => {
    if (currentPage > 1) {
      onPageChange(currentPage - 1)
    }
  }

  const handleNext = () => {
    if (currentPage < totalPages) {
      onPageChange(currentPage + 1)
    }
  }

  return (
    <nav className="pagination" aria-label="Navegación de páginas">
      
      <div className="pagination-controls">
       

        <button
          className="pagination-btn"
          onClick={handlePrevious}
          disabled={currentPage === 1}
          aria-label="Página anterior"
          title="Página anterior"
        >
          <ChevronLeft size={16} />
        </button>

        <div className="pagination-numbers">
          {visiblePages.map((page, index) => (
            <button
              key={index}
              className={`pagination-number ${page === currentPage ? "active" : ""} ${page === "..." ? "dots" : ""}`}
              onClick={() => typeof page === "number" && onPageChange(page)}
              disabled={page === "..." || page === currentPage}
              aria-label={typeof page === "number" ? `Ir a página ${page}` : "Más páginas"}
              aria-current={page === currentPage ? "page" : undefined}
            >
              {page}
            </button>
          ))}
        </div>

        <button
          className="pagination-btn"
          onClick={handleNext}
          disabled={currentPage === totalPages}
          aria-label="Página siguiente"
          title="Página siguiente"
        >
          <ChevronRight size={16} />
        </button>

        
      </div>
    </nav>
  )
}
