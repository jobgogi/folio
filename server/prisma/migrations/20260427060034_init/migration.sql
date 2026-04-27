-- CreateEnum
CREATE TYPE "book_type" AS ENUM ('PDF', 'EPUB');

-- CreateEnum
CREATE TYPE "reading_direction" AS ENUM ('LTR', 'RTL', 'TTB');

-- CreateTable
CREATE TABLE "books" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "type" "book_type" NOT NULL,
    "path" TEXT NOT NULL,
    "size" INTEGER NOT NULL,
    "last_sync_at" TIMESTAMP(3) NOT NULL,
    "title" TEXT NOT NULL,
    "author" TEXT,
    "isbn" TEXT,
    "publisher" TEXT,
    "published_at" TIMESTAMP(3),
    "thumbnail" TEXT,
    "reading_direction" "reading_direction",
    "last_opened_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "books_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "books_path_key" ON "books"("path");
