import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/task_bloc.dart';
import 'bloc/task_event.dart';
import 'core/constants/api_constants.dart';
import 'core/network/dio_client.dart';
import 'data/datasources/task_remote_datasource.dart';
import 'data/repositories/task_repository.dart';
import 'presentation/screens/task_list_screen.dart';

void main() {
  final dioClient = DioClient(baseUrl: ApiConstants.baseUrl);
  final dataSource = TaskRemoteDataSource(dioClient.dio);
  final repository = TaskRepository(dataSource);

  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.repository});

  final TaskRepository? repository;

  @override
  Widget build(BuildContext context) {
    final repositoryInstance = repository ??
        TaskRepository(
          TaskRemoteDataSource(
            DioClient(baseUrl: ApiConstants.baseUrl).dio,
          ),
        );

    return BlocProvider(
      create: (_) => TaskBloc(repositoryInstance)..add(const LoadTasks()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Todo App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF5D479D),
            surface: const Color(0xFFF5F6FA),
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F6FA),
          appBarTheme: const AppBarTheme(centerTitle: true),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF5D479D)),
            ),
          ),
        ),
        home: const TaskListScreen(),
      ),
    );
  }
}