import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/core/usecase/usecase.dart';
import 'package:audiobooks/features/home/domain/repositories/home_repository.dart';
import 'package:audiobooks/features/home/presentation/bloc/book_detailed/book_detailed_bloc.dart';
import 'package:dartz/dartz.dart';

class UBookDetailedDownload extends UseCase<bool, DownloadBookEvent> {
  final HomeRepository homeRepository;

  UBookDetailedDownload({required this.homeRepository});

  @override
  Future<Either<Failure, bool>> call(DownloadBookEvent event) {
    return homeRepository.downloadAndAddPlaylist(event.book);
  }
}