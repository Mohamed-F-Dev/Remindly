import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:remindly/data/datasources/local_data_sources.dart';
import 'package:remindly/data/repo_impl/reminder_repo_impl.dart';
import 'package:remindly/domain/model/parereminder_typadapter.dart';
import 'package:remindly/domain/model/parse_reminder.dart';
import 'package:remindly/domain/model/token_type_adapter.dart';
import 'package:remindly/domain/parser/reminder_parser.dart';
import 'package:remindly/domain/repo/reminder_repo.dart';
import 'package:remindly/domain/usecase/add_reminder.dart';
import 'package:remindly/domain/usecase/get_reminders.dart';
import 'package:remindly/ui/bloc/local_reminder_cubit/local_reminder_cubit.dart';
import 'package:remindly/ui/bloc/reminder_cubit/reminder_cubit.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  // Here you can register your dependencies
  // hive
  Hive.registerAdapter(TokenAdapter());
  Hive.registerAdapter(ParsedReminderTypeAdapter());

  final box = await Hive.openBox("remindly_box");

  //data sources
  sl.registerLazySingleton<LocalDataSources>(() => LocalDataSourcesImpl(box));

  // repositories
  sl.registerLazySingleton<ReminderRepositories>(
    () => ReminderRepositoriesImpl(
      parser: ReminderParser(),
      localDataSources: sl<LocalDataSources>(),
    ),
  );

  //use cases ;
  sl.registerLazySingleton<AddReminderUseCase>(
    () => AddReminderUseCase(repo: sl<ReminderRepositories>()),
  );
  sl.registerLazySingleton<GetRemindersUseCase>(
    () => GetRemindersUseCase(sl<ReminderRepositories>()),
  );

  // cubit
  sl.registerFactory<ReminderCubit>(
    () => ReminderCubit(sl<AddReminderUseCase>()),
  );
  sl.registerFactory<LocalReminderCubit>(
    () => LocalReminderCubit(sl<GetRemindersUseCase>()),
  );
}
