/**
 * @description PDF/ePub 파일에서 메타데이터를 추출하는 서비스
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see SyncModule
 */
import { Injectable } from '@nestjs/common';
import * as fs from 'fs';
import * as path from 'path';
import pdfParse from 'pdf-parse';
import AdmZip from 'adm-zip';
import { XMLParser } from 'fast-xml-parser';

export interface BookMeta {
  title: string;
  author?: string;
  isbn?: string;
  publisher?: string;
  publishedAt?: Date;
  thumbnail?: string;
  readingDirection?: 'LTR' | 'RTL' | 'TTB';
}

const DIRECTION_MAP: Record<string, 'LTR' | 'RTL' | 'TTB'> = {
  ltr: 'LTR',
  rtl: 'RTL',
  ttb: 'TTB',
};

@Injectable()
export class BookMetaExtractService {
  /**
   * @description 파일 타입에 따라 메타데이터를 추출한다. 실패 시 파일명을 title로 fallback한다.
   * @param {string} filePath 파일 절대 경로
   * @param {'PDF' | 'EPUB'} type 파일 타입
   * @param {string} fileName 파일명 (fallback용)
   * @returns {Promise<BookMeta>} 추출된 메타데이터
   */
  async extract(filePath: string, type: 'PDF' | 'EPUB', fileName: string): Promise<BookMeta> {
    const baseName = path.basename(fileName, path.extname(fileName));
    try {
      const meta = type === 'PDF'
        ? await this.extractPdf(filePath)
        : await this.extractEpub(filePath);
      return meta as BookMeta;
    } catch {
      return { title: baseName };
    }
  }

  /**
   * @description PDF 내장 메타데이터(제목, 저자)를 추출한다.
   * @param {string} filePath PDF 파일 경로
   * @returns {Promise<Partial<BookMeta>>} 추출된 메타데이터
   */
  private async extractPdf(filePath: string): Promise<Partial<BookMeta>> {
    const buffer = await fs.promises.readFile(filePath);
    const data = await pdfParse(buffer);
    return {
      title: data.info?.Title || undefined,
      author: data.info?.Author || undefined,
    };
  }

  /**
   * @description ePub OPF에서 메타데이터 및 읽기 방향을 추출한다.
   * @param {string} filePath ePub 파일 경로
   * @returns {Promise<Partial<BookMeta>>} 추출된 메타데이터
   */
  private async extractEpub(filePath: string): Promise<Partial<BookMeta>> {
    const zip = new AdmZip(filePath);
    const parser = new XMLParser({ ignoreAttributes: false, attributeNamePrefix: '@_' });

    // container.xml에서 OPF 경로 확인
    const containerXml = zip.readAsText('META-INF/container.xml');
    const container = parser.parse(containerXml);
    const opfPath = container?.container?.rootfiles?.rootfile?.['@_full-path'];

    if (!opfPath) throw new Error('OPF 경로를 찾을 수 없습니다.');

    const opfXml = zip.readAsText(opfPath);
    const opf = parser.parse(opfXml);
    const metadata = opf?.package?.metadata;
    const spine = opf?.package?.spine;

    const rawDirection = spine?.['@_page-progression-direction'];
    const readingDirection = rawDirection ? DIRECTION_MAP[rawDirection] : undefined;

    const publishedRaw = metadata?.['dc:date'];
    const publishedAt = publishedRaw ? new Date(publishedRaw) : undefined;

    return {
      title: metadata?.['dc:title'] || undefined,
      author: metadata?.['dc:creator'] || undefined,
      isbn: metadata?.['dc:identifier'] || undefined,
      publisher: metadata?.['dc:publisher'] || undefined,
      publishedAt,
      readingDirection,
    };
  }
}
