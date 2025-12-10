class DownloadAppUpdateParams {
  final String downloadUrl;
  final String fileName;
  final void Function(int received, int total)? onProgress;
  final bool Function()? isCancelled;

  const DownloadAppUpdateParams({
    required this.downloadUrl,
    required this.fileName,
    this.onProgress,
    this.isCancelled,
  });
}
