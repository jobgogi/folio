export class FileDto {
  id: string;
  name: string;
  type: 'pdf' | 'epub' | 'unknown';
  path: string;
  lastOpenedAt: string | null;
}
