import 'package:flutter/material.dart';

import '../../../../core/widgets/module_list_page.dart';
import '../../data/lms_repository.dart';
import 'lms_course_detail_page.dart';

/// LMS: katalog kursus + enroll.
/// Backend: `/lms/courses`, `/lms/enroll`.
class LmsCoursesPage extends StatelessWidget {
  const LmsCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LmsRepository repo = LmsRepository();
    return ModuleListPage(
      title: 'LMS',
      loader: repo.courses,
      emptyText: 'Belum ada kursus.',
      itemBuilder: (BuildContext c, Map<String, dynamic> e) {
        final int id = (e['id'] as num).toInt();
        return Card(
          child: ListTile(
            leading: const Icon(Icons.play_lesson_outlined),
            title: Text(e['title']?.toString() ?? '-'),
            subtitle: Text(e['description']?.toString() ?? '-',
                maxLines: 2, overflow: TextOverflow.ellipsis),
            onTap: () => Navigator.of(c).push(
              MaterialPageRoute<void>(
                builder: (_) => LmsCourseDetailPage(
                    courseId: id, title: e['title']?.toString() ?? 'Kursus'),
              ),
            ),
          ),
        );
      },
    );
  }
}
