# 테스트 패턴

## AAA 패턴 (필수)
// Arrange: 준비
// Act: 실행
// Assert: 검증

## Flutter Unit Test 예시
test('PDF MIME 타입이면 pdf를 반환한다', () {
  // Arrange
  final detector = FileDetector();
  // Act
  final result = detector.detect('application/pdf', 'book.pdf');
  // Assert
  expect(result, FileType.pdf);
});

test('지원하지 않는 타입이면 unknown을 반환한다', () {
  final detector = FileDetector();
  final result = detector.detect('text/plain', 'doc.txt');
  expect(result, FileType.unknown);
});

## NestJS Unit Test 예시
it('파일 목록을 반환한다', async () => {
  // Arrange
  const files = [{ name: 'book.pdf', type: 'pdf' }];
  jest.spyOn(nasService, 'listFiles').mockResolvedValue(files);
  // Act
  const result = await filesService.getFiles();
  // Assert
  expect(result).toEqual(files);
});