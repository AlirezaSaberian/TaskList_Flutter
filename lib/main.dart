import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_list/data.dart';
import 'package:task_list/edit.dart';

const taskBoxName = 'tasks';
void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(PriorityAdapter());
  await Hive.openBox<TaskEntity>(taskBoxName);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: primaryContainerColor),
  );
  runApp(const MyApp());
}

const Color primaryColor = Color(0xff794CFF);
const Color primaryContainerColor = Color(0xff5C0AFF);
const secondaryTextColor = Color(0xffAFBED0);
const highPriority = primaryColor;
const normalPriority = Color(0xffF09819);
const lowPriority = Color(0xff3BE1F1);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryTextColor = Color(0xff1D2830);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
          const TextTheme(
            titleLarge: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: secondaryTextColor),
          iconColor: secondaryTextColor,
          border: InputBorder.none,
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
        colorScheme: const ColorScheme.light(
          primary: primaryColor,
          primaryContainer: primaryContainerColor,
          onPrimary: Colors.white,
          background: Color(0xffF3F5F8),
          onBackground: primaryTextColor,
          onSurface: primaryTextColor,
          secondary: primaryColor,
          onSecondary: Colors.white,
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final TextEditingController controller = TextEditingController();
  final ValueNotifier<String> searchKeywordNotifier = ValueNotifier('');

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<TaskEntity>(taskBoxName);
    final themeData = Theme.of(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditTaskScreen(
                task: TaskEntity(),
              ),
            ),
          );
        },
        label: const Row(
          children: [
            Text('Add New Task'),
            SizedBox(
              width: 4,
            ),
            Icon(CupertinoIcons.add, size: 18)
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    themeData.colorScheme.primary,
                    themeData.colorScheme.primaryContainer
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'To Do List',
                          style: themeData.textTheme.titleLarge!
                              .apply(color: Colors.white),
                        ),
                        Icon(
                          CupertinoIcons.share,
                          color: themeData.colorScheme.onPrimary,
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Container(
                      height: 38,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(19),
                        color: themeData.colorScheme.onPrimary,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) {
                          searchKeywordNotifier.value = controller.text;
                        },
                        controller: controller,
                        decoration: const InputDecoration(
                            prefixIcon: Icon(CupertinoIcons.search),
                            label: Text('Search tasks...')),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder(
                builder: (context, value, child) {
                  return ValueListenableBuilder<Box<TaskEntity>>(
                    valueListenable: box.listenable(),
                    builder: (BuildContext context, box, Widget? child) {
                      final List<TaskEntity> items;
                      if (controller.text.isEmpty) {
                        items = box.values.toList();
                      } else {
                        items = box.values
                            .where(
                                (task) => task.name.contains(controller.text))
                            .toList();
                      }

                      if (items.isNotEmpty) {
                        return ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                            itemCount: items.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Today',
                                          style: themeData.textTheme.titleLarge!
                                              .apply(fontSizeFactor: 0.9),
                                        ),
                                        Container(
                                          width: 70,
                                          height: 3,
                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(1.5),
                                          ),
                                        )
                                      ],
                                    ),
                                    MaterialButton(
                                      onPressed: () {
                                        box.clear();
                                      },
                                      elevation: 0,
                                      color: const Color(0xffEAEFF5),
                                      textColor: secondaryTextColor,
                                      child: const Row(
                                        children: [
                                          Text('Delete All'),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Icon(CupertinoIcons.delete_solid,
                                              size: 18)
                                        ],
                                      ),
                                    )
                                  ],
                                );
                              } else {
                                final TaskEntity task = items[index - 1];
                                return TaskItem(task: task);
                              }
                            });
                      } else {
                        return const EmptyState();
                      }
                    },
                  );
                },
                valueListenable: searchKeywordNotifier,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/empty_state.svg',
          width: 120,
        ),
        const SizedBox(
          height: 12,
        ),
        const Text('Your task list is empty')
      ],
    );
  }
}

class TaskItem extends StatefulWidget {
  static const double height = 78;
  const TaskItem({
    super.key,
    required this.task,
  });

  final TaskEntity task;

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final Color priorityColor;

    switch (widget.task.priority) {
      case Priority.high:
        priorityColor = highPriority;
        break;
      case Priority.normal:
        priorityColor = normalPriority;
        break;
      case Priority.low:
        priorityColor = lowPriority;
        break;
    }

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditTaskScreen(task: widget.task),
          ),
        );
      },
      onLongPress: () {
        widget.task.delete();
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.only(left: 16),
        height: TaskItem.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: themeData.colorScheme.surface,
        ),
        child: Row(
          children: [
            MyCheckBox(
              value: widget.task.isCompleted,
              onTap: () {
                setState(() {
                  widget.task.isCompleted = !widget.task.isCompleted;
                });
              },
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: Text(
                widget.task.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 16,
                    decoration: widget.task.isCompleted
                        ? TextDecoration.lineThrough
                        : null),
              ),
            ),
            Container(
              height: TaskItem.height,
              width: 5,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MyCheckBox extends StatelessWidget {
  const MyCheckBox({super.key, required this.value, required this.onTap});
  final bool value;
  final GestureTapCallback onTap;
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 24,
        width: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border:
              value ? null : Border.all(color: secondaryTextColor, width: 2),
          color: value ? primaryColor : null,
        ),
        child: value
            ? Icon(
                CupertinoIcons.check_mark,
                size: 16,
                color: themeData.colorScheme.onPrimary,
              )
            : null,
      ),
    );
  }
}
