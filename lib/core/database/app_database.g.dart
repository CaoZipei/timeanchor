// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $GoalsTable extends Goals with TableInfo<$GoalsTable, Goal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _plannedDurationMeta =
      const VerificationMeta('plannedDuration');
  @override
  late final GeneratedColumn<int> plannedDuration = GeneratedColumn<int>(
      'planned_duration', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _actualDurationMeta =
      const VerificationMeta('actualDuration');
  @override
  late final GeneratedColumn<int> actualDuration = GeneratedColumn<int>(
      'actual_duration', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<int> startTime = GeneratedColumn<int>(
      'start_time', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<int> endTime = GeneratedColumn<int>(
      'end_time', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _completedMeta =
      const VerificationMeta('completed');
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
      'completed', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("completed" IN (0, 1))'));
  static const VerificationMeta _userNoteMeta =
      const VerificationMeta('userNote');
  @override
  late final GeneratedColumn<String> userNote = GeneratedColumn<String>(
      'user_note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _aiReviewTextMeta =
      const VerificationMeta('aiReviewText');
  @override
  late final GeneratedColumn<String> aiReviewText = GeneratedColumn<String>(
      'ai_review_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _aiReviewFeedbackMeta =
      const VerificationMeta('aiReviewFeedback');
  @override
  late final GeneratedColumn<int> aiReviewFeedback = GeneratedColumn<int>(
      'ai_review_feedback', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        description,
        plannedDuration,
        actualDuration,
        startTime,
        endTime,
        status,
        completed,
        userNote,
        aiReviewText,
        aiReviewFeedback,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(Insertable<Goal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('planned_duration')) {
      context.handle(
          _plannedDurationMeta,
          plannedDuration.isAcceptableOrUnknown(
              data['planned_duration']!, _plannedDurationMeta));
    } else if (isInserting) {
      context.missing(_plannedDurationMeta);
    }
    if (data.containsKey('actual_duration')) {
      context.handle(
          _actualDurationMeta,
          actualDuration.isAcceptableOrUnknown(
              data['actual_duration']!, _actualDurationMeta));
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(_completedMeta,
          completed.isAcceptableOrUnknown(data['completed']!, _completedMeta));
    }
    if (data.containsKey('user_note')) {
      context.handle(_userNoteMeta,
          userNote.isAcceptableOrUnknown(data['user_note']!, _userNoteMeta));
    }
    if (data.containsKey('ai_review_text')) {
      context.handle(
          _aiReviewTextMeta,
          aiReviewText.isAcceptableOrUnknown(
              data['ai_review_text']!, _aiReviewTextMeta));
    }
    if (data.containsKey('ai_review_feedback')) {
      context.handle(
          _aiReviewFeedbackMeta,
          aiReviewFeedback.isAcceptableOrUnknown(
              data['ai_review_feedback']!, _aiReviewFeedbackMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Goal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Goal(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      plannedDuration: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}planned_duration'])!,
      actualDuration: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}actual_duration']),
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_time']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      completed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}completed']),
      userNote: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_note']),
      aiReviewText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ai_review_text']),
      aiReviewFeedback: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ai_review_feedback']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class Goal extends DataClass implements Insertable<Goal> {
  final int id;
  final String title;
  final String? description;
  final int plannedDuration;
  final int? actualDuration;
  final int startTime;
  final int? endTime;
  final String status;
  final bool? completed;
  final String? userNote;
  final String? aiReviewText;
  final int? aiReviewFeedback;
  final DateTime createdAt;
  const Goal(
      {required this.id,
      required this.title,
      this.description,
      required this.plannedDuration,
      this.actualDuration,
      required this.startTime,
      this.endTime,
      required this.status,
      this.completed,
      this.userNote,
      this.aiReviewText,
      this.aiReviewFeedback,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['planned_duration'] = Variable<int>(plannedDuration);
    if (!nullToAbsent || actualDuration != null) {
      map['actual_duration'] = Variable<int>(actualDuration);
    }
    map['start_time'] = Variable<int>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<int>(endTime);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || completed != null) {
      map['completed'] = Variable<bool>(completed);
    }
    if (!nullToAbsent || userNote != null) {
      map['user_note'] = Variable<String>(userNote);
    }
    if (!nullToAbsent || aiReviewText != null) {
      map['ai_review_text'] = Variable<String>(aiReviewText);
    }
    if (!nullToAbsent || aiReviewFeedback != null) {
      map['ai_review_feedback'] = Variable<int>(aiReviewFeedback);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      plannedDuration: Value(plannedDuration),
      actualDuration: actualDuration == null && nullToAbsent
          ? const Value.absent()
          : Value(actualDuration),
      startTime: Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      status: Value(status),
      completed: completed == null && nullToAbsent
          ? const Value.absent()
          : Value(completed),
      userNote: userNote == null && nullToAbsent
          ? const Value.absent()
          : Value(userNote),
      aiReviewText: aiReviewText == null && nullToAbsent
          ? const Value.absent()
          : Value(aiReviewText),
      aiReviewFeedback: aiReviewFeedback == null && nullToAbsent
          ? const Value.absent()
          : Value(aiReviewFeedback),
      createdAt: Value(createdAt),
    );
  }

  factory Goal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Goal(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      plannedDuration: serializer.fromJson<int>(json['plannedDuration']),
      actualDuration: serializer.fromJson<int?>(json['actualDuration']),
      startTime: serializer.fromJson<int>(json['startTime']),
      endTime: serializer.fromJson<int?>(json['endTime']),
      status: serializer.fromJson<String>(json['status']),
      completed: serializer.fromJson<bool?>(json['completed']),
      userNote: serializer.fromJson<String?>(json['userNote']),
      aiReviewText: serializer.fromJson<String?>(json['aiReviewText']),
      aiReviewFeedback: serializer.fromJson<int?>(json['aiReviewFeedback']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'plannedDuration': serializer.toJson<int>(plannedDuration),
      'actualDuration': serializer.toJson<int?>(actualDuration),
      'startTime': serializer.toJson<int>(startTime),
      'endTime': serializer.toJson<int?>(endTime),
      'status': serializer.toJson<String>(status),
      'completed': serializer.toJson<bool?>(completed),
      'userNote': serializer.toJson<String?>(userNote),
      'aiReviewText': serializer.toJson<String?>(aiReviewText),
      'aiReviewFeedback': serializer.toJson<int?>(aiReviewFeedback),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Goal copyWith(
          {int? id,
          String? title,
          Value<String?> description = const Value.absent(),
          int? plannedDuration,
          Value<int?> actualDuration = const Value.absent(),
          int? startTime,
          Value<int?> endTime = const Value.absent(),
          String? status,
          Value<bool?> completed = const Value.absent(),
          Value<String?> userNote = const Value.absent(),
          Value<String?> aiReviewText = const Value.absent(),
          Value<int?> aiReviewFeedback = const Value.absent(),
          DateTime? createdAt}) =>
      Goal(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        plannedDuration: plannedDuration ?? this.plannedDuration,
        actualDuration:
            actualDuration.present ? actualDuration.value : this.actualDuration,
        startTime: startTime ?? this.startTime,
        endTime: endTime.present ? endTime.value : this.endTime,
        status: status ?? this.status,
        completed: completed.present ? completed.value : this.completed,
        userNote: userNote.present ? userNote.value : this.userNote,
        aiReviewText:
            aiReviewText.present ? aiReviewText.value : this.aiReviewText,
        aiReviewFeedback: aiReviewFeedback.present
            ? aiReviewFeedback.value
            : this.aiReviewFeedback,
        createdAt: createdAt ?? this.createdAt,
      );
  Goal copyWithCompanion(GoalsCompanion data) {
    return Goal(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      plannedDuration: data.plannedDuration.present
          ? data.plannedDuration.value
          : this.plannedDuration,
      actualDuration: data.actualDuration.present
          ? data.actualDuration.value
          : this.actualDuration,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      status: data.status.present ? data.status.value : this.status,
      completed: data.completed.present ? data.completed.value : this.completed,
      userNote: data.userNote.present ? data.userNote.value : this.userNote,
      aiReviewText: data.aiReviewText.present
          ? data.aiReviewText.value
          : this.aiReviewText,
      aiReviewFeedback: data.aiReviewFeedback.present
          ? data.aiReviewFeedback.value
          : this.aiReviewFeedback,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Goal(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('plannedDuration: $plannedDuration, ')
          ..write('actualDuration: $actualDuration, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('status: $status, ')
          ..write('completed: $completed, ')
          ..write('userNote: $userNote, ')
          ..write('aiReviewText: $aiReviewText, ')
          ..write('aiReviewFeedback: $aiReviewFeedback, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      description,
      plannedDuration,
      actualDuration,
      startTime,
      endTime,
      status,
      completed,
      userNote,
      aiReviewText,
      aiReviewFeedback,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Goal &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.plannedDuration == this.plannedDuration &&
          other.actualDuration == this.actualDuration &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.status == this.status &&
          other.completed == this.completed &&
          other.userNote == this.userNote &&
          other.aiReviewText == this.aiReviewText &&
          other.aiReviewFeedback == this.aiReviewFeedback &&
          other.createdAt == this.createdAt);
}

class GoalsCompanion extends UpdateCompanion<Goal> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<int> plannedDuration;
  final Value<int?> actualDuration;
  final Value<int> startTime;
  final Value<int?> endTime;
  final Value<String> status;
  final Value<bool?> completed;
  final Value<String?> userNote;
  final Value<String?> aiReviewText;
  final Value<int?> aiReviewFeedback;
  final Value<DateTime> createdAt;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.plannedDuration = const Value.absent(),
    this.actualDuration = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.status = const Value.absent(),
    this.completed = const Value.absent(),
    this.userNote = const Value.absent(),
    this.aiReviewText = const Value.absent(),
    this.aiReviewFeedback = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  GoalsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required int plannedDuration,
    this.actualDuration = const Value.absent(),
    required int startTime,
    this.endTime = const Value.absent(),
    required String status,
    this.completed = const Value.absent(),
    this.userNote = const Value.absent(),
    this.aiReviewText = const Value.absent(),
    this.aiReviewFeedback = const Value.absent(),
    required DateTime createdAt,
  })  : title = Value(title),
        plannedDuration = Value(plannedDuration),
        startTime = Value(startTime),
        status = Value(status),
        createdAt = Value(createdAt);
  static Insertable<Goal> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? plannedDuration,
    Expression<int>? actualDuration,
    Expression<int>? startTime,
    Expression<int>? endTime,
    Expression<String>? status,
    Expression<bool>? completed,
    Expression<String>? userNote,
    Expression<String>? aiReviewText,
    Expression<int>? aiReviewFeedback,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (plannedDuration != null) 'planned_duration': plannedDuration,
      if (actualDuration != null) 'actual_duration': actualDuration,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (status != null) 'status': status,
      if (completed != null) 'completed': completed,
      if (userNote != null) 'user_note': userNote,
      if (aiReviewText != null) 'ai_review_text': aiReviewText,
      if (aiReviewFeedback != null) 'ai_review_feedback': aiReviewFeedback,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  GoalsCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String?>? description,
      Value<int>? plannedDuration,
      Value<int?>? actualDuration,
      Value<int>? startTime,
      Value<int?>? endTime,
      Value<String>? status,
      Value<bool?>? completed,
      Value<String?>? userNote,
      Value<String?>? aiReviewText,
      Value<int?>? aiReviewFeedback,
      Value<DateTime>? createdAt}) {
    return GoalsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      plannedDuration: plannedDuration ?? this.plannedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      completed: completed ?? this.completed,
      userNote: userNote ?? this.userNote,
      aiReviewText: aiReviewText ?? this.aiReviewText,
      aiReviewFeedback: aiReviewFeedback ?? this.aiReviewFeedback,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (plannedDuration.present) {
      map['planned_duration'] = Variable<int>(plannedDuration.value);
    }
    if (actualDuration.present) {
      map['actual_duration'] = Variable<int>(actualDuration.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<int>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<int>(endTime.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (userNote.present) {
      map['user_note'] = Variable<String>(userNote.value);
    }
    if (aiReviewText.present) {
      map['ai_review_text'] = Variable<String>(aiReviewText.value);
    }
    if (aiReviewFeedback.present) {
      map['ai_review_feedback'] = Variable<int>(aiReviewFeedback.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('plannedDuration: $plannedDuration, ')
          ..write('actualDuration: $actualDuration, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('status: $status, ')
          ..write('completed: $completed, ')
          ..write('userNote: $userNote, ')
          ..write('aiReviewText: $aiReviewText, ')
          ..write('aiReviewFeedback: $aiReviewFeedback, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AppUsageRecordsTable extends AppUsageRecords
    with TableInfo<$AppUsageRecordsTable, AppUsageRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppUsageRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _packageNameMeta =
      const VerificationMeta('packageName');
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
      'package_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _appNameMeta =
      const VerificationMeta('appName');
  @override
  late final GeneratedColumn<String> appName = GeneratedColumn<String>(
      'app_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _appCategoryMeta =
      const VerificationMeta('appCategory');
  @override
  late final GeneratedColumn<String> appCategory = GeneratedColumn<String>(
      'app_category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('other'));
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<int> startTime = GeneratedColumn<int>(
      'start_time', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<int> endTime = GeneratedColumn<int>(
      'end_time', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _durationMeta =
      const VerificationMeta('duration');
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
      'duration', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _launchCountMeta =
      const VerificationMeta('launchCount');
  @override
  late final GeneratedColumn<int> launchCount = GeneratedColumn<int>(
      'launch_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<int> goalId = GeneratedColumn<int>(
      'goal_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES goals (id)'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        packageName,
        appName,
        appCategory,
        startTime,
        endTime,
        duration,
        date,
        launchCount,
        goalId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_usage_records';
  @override
  VerificationContext validateIntegrity(Insertable<AppUsageRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('package_name')) {
      context.handle(
          _packageNameMeta,
          packageName.isAcceptableOrUnknown(
              data['package_name']!, _packageNameMeta));
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('app_name')) {
      context.handle(_appNameMeta,
          appName.isAcceptableOrUnknown(data['app_name']!, _appNameMeta));
    } else if (isInserting) {
      context.missing(_appNameMeta);
    }
    if (data.containsKey('app_category')) {
      context.handle(
          _appCategoryMeta,
          appCategory.isAcceptableOrUnknown(
              data['app_category']!, _appCategoryMeta));
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('duration')) {
      context.handle(_durationMeta,
          duration.isAcceptableOrUnknown(data['duration']!, _durationMeta));
    } else if (isInserting) {
      context.missing(_durationMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('launch_count')) {
      context.handle(
          _launchCountMeta,
          launchCount.isAcceptableOrUnknown(
              data['launch_count']!, _launchCountMeta));
    }
    if (data.containsKey('goal_id')) {
      context.handle(_goalIdMeta,
          goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppUsageRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppUsageRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      packageName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}package_name'])!,
      appName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}app_name'])!,
      appCategory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}app_category'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_time'])!,
      duration: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      launchCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}launch_count'])!,
      goalId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}goal_id']),
    );
  }

  @override
  $AppUsageRecordsTable createAlias(String alias) {
    return $AppUsageRecordsTable(attachedDatabase, alias);
  }
}

class AppUsageRecord extends DataClass implements Insertable<AppUsageRecord> {
  final int id;
  final String packageName;
  final String appName;
  final String appCategory;
  final int startTime;
  final int endTime;
  final int duration;
  final DateTime date;
  final int launchCount;
  final int? goalId;
  const AppUsageRecord(
      {required this.id,
      required this.packageName,
      required this.appName,
      required this.appCategory,
      required this.startTime,
      required this.endTime,
      required this.duration,
      required this.date,
      required this.launchCount,
      this.goalId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['package_name'] = Variable<String>(packageName);
    map['app_name'] = Variable<String>(appName);
    map['app_category'] = Variable<String>(appCategory);
    map['start_time'] = Variable<int>(startTime);
    map['end_time'] = Variable<int>(endTime);
    map['duration'] = Variable<int>(duration);
    map['date'] = Variable<DateTime>(date);
    map['launch_count'] = Variable<int>(launchCount);
    if (!nullToAbsent || goalId != null) {
      map['goal_id'] = Variable<int>(goalId);
    }
    return map;
  }

  AppUsageRecordsCompanion toCompanion(bool nullToAbsent) {
    return AppUsageRecordsCompanion(
      id: Value(id),
      packageName: Value(packageName),
      appName: Value(appName),
      appCategory: Value(appCategory),
      startTime: Value(startTime),
      endTime: Value(endTime),
      duration: Value(duration),
      date: Value(date),
      launchCount: Value(launchCount),
      goalId:
          goalId == null && nullToAbsent ? const Value.absent() : Value(goalId),
    );
  }

  factory AppUsageRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppUsageRecord(
      id: serializer.fromJson<int>(json['id']),
      packageName: serializer.fromJson<String>(json['packageName']),
      appName: serializer.fromJson<String>(json['appName']),
      appCategory: serializer.fromJson<String>(json['appCategory']),
      startTime: serializer.fromJson<int>(json['startTime']),
      endTime: serializer.fromJson<int>(json['endTime']),
      duration: serializer.fromJson<int>(json['duration']),
      date: serializer.fromJson<DateTime>(json['date']),
      launchCount: serializer.fromJson<int>(json['launchCount']),
      goalId: serializer.fromJson<int?>(json['goalId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'packageName': serializer.toJson<String>(packageName),
      'appName': serializer.toJson<String>(appName),
      'appCategory': serializer.toJson<String>(appCategory),
      'startTime': serializer.toJson<int>(startTime),
      'endTime': serializer.toJson<int>(endTime),
      'duration': serializer.toJson<int>(duration),
      'date': serializer.toJson<DateTime>(date),
      'launchCount': serializer.toJson<int>(launchCount),
      'goalId': serializer.toJson<int?>(goalId),
    };
  }

  AppUsageRecord copyWith(
          {int? id,
          String? packageName,
          String? appName,
          String? appCategory,
          int? startTime,
          int? endTime,
          int? duration,
          DateTime? date,
          int? launchCount,
          Value<int?> goalId = const Value.absent()}) =>
      AppUsageRecord(
        id: id ?? this.id,
        packageName: packageName ?? this.packageName,
        appName: appName ?? this.appName,
        appCategory: appCategory ?? this.appCategory,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        duration: duration ?? this.duration,
        date: date ?? this.date,
        launchCount: launchCount ?? this.launchCount,
        goalId: goalId.present ? goalId.value : this.goalId,
      );
  AppUsageRecord copyWithCompanion(AppUsageRecordsCompanion data) {
    return AppUsageRecord(
      id: data.id.present ? data.id.value : this.id,
      packageName:
          data.packageName.present ? data.packageName.value : this.packageName,
      appName: data.appName.present ? data.appName.value : this.appName,
      appCategory:
          data.appCategory.present ? data.appCategory.value : this.appCategory,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      duration: data.duration.present ? data.duration.value : this.duration,
      date: data.date.present ? data.date.value : this.date,
      launchCount:
          data.launchCount.present ? data.launchCount.value : this.launchCount,
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppUsageRecord(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('appName: $appName, ')
          ..write('appCategory: $appCategory, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('duration: $duration, ')
          ..write('date: $date, ')
          ..write('launchCount: $launchCount, ')
          ..write('goalId: $goalId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, packageName, appName, appCategory,
      startTime, endTime, duration, date, launchCount, goalId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppUsageRecord &&
          other.id == this.id &&
          other.packageName == this.packageName &&
          other.appName == this.appName &&
          other.appCategory == this.appCategory &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.duration == this.duration &&
          other.date == this.date &&
          other.launchCount == this.launchCount &&
          other.goalId == this.goalId);
}

class AppUsageRecordsCompanion extends UpdateCompanion<AppUsageRecord> {
  final Value<int> id;
  final Value<String> packageName;
  final Value<String> appName;
  final Value<String> appCategory;
  final Value<int> startTime;
  final Value<int> endTime;
  final Value<int> duration;
  final Value<DateTime> date;
  final Value<int> launchCount;
  final Value<int?> goalId;
  const AppUsageRecordsCompanion({
    this.id = const Value.absent(),
    this.packageName = const Value.absent(),
    this.appName = const Value.absent(),
    this.appCategory = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.duration = const Value.absent(),
    this.date = const Value.absent(),
    this.launchCount = const Value.absent(),
    this.goalId = const Value.absent(),
  });
  AppUsageRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String packageName,
    required String appName,
    this.appCategory = const Value.absent(),
    required int startTime,
    required int endTime,
    required int duration,
    required DateTime date,
    this.launchCount = const Value.absent(),
    this.goalId = const Value.absent(),
  })  : packageName = Value(packageName),
        appName = Value(appName),
        startTime = Value(startTime),
        endTime = Value(endTime),
        duration = Value(duration),
        date = Value(date);
  static Insertable<AppUsageRecord> custom({
    Expression<int>? id,
    Expression<String>? packageName,
    Expression<String>? appName,
    Expression<String>? appCategory,
    Expression<int>? startTime,
    Expression<int>? endTime,
    Expression<int>? duration,
    Expression<DateTime>? date,
    Expression<int>? launchCount,
    Expression<int>? goalId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packageName != null) 'package_name': packageName,
      if (appName != null) 'app_name': appName,
      if (appCategory != null) 'app_category': appCategory,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (duration != null) 'duration': duration,
      if (date != null) 'date': date,
      if (launchCount != null) 'launch_count': launchCount,
      if (goalId != null) 'goal_id': goalId,
    });
  }

  AppUsageRecordsCompanion copyWith(
      {Value<int>? id,
      Value<String>? packageName,
      Value<String>? appName,
      Value<String>? appCategory,
      Value<int>? startTime,
      Value<int>? endTime,
      Value<int>? duration,
      Value<DateTime>? date,
      Value<int>? launchCount,
      Value<int?>? goalId}) {
    return AppUsageRecordsCompanion(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      appCategory: appCategory ?? this.appCategory,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      date: date ?? this.date,
      launchCount: launchCount ?? this.launchCount,
      goalId: goalId ?? this.goalId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (appName.present) {
      map['app_name'] = Variable<String>(appName.value);
    }
    if (appCategory.present) {
      map['app_category'] = Variable<String>(appCategory.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<int>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<int>(endTime.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (launchCount.present) {
      map['launch_count'] = Variable<int>(launchCount.value);
    }
    if (goalId.present) {
      map['goal_id'] = Variable<int>(goalId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppUsageRecordsCompanion(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('appName: $appName, ')
          ..write('appCategory: $appCategory, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('duration: $duration, ')
          ..write('date: $date, ')
          ..write('launchCount: $launchCount, ')
          ..write('goalId: $goalId')
          ..write(')'))
        .toString();
  }
}

class $UserLabelsTable extends UserLabels
    with TableInfo<$UserLabelsTable, UserLabel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserLabelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
      'emoji', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
      'color', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isPresetMeta =
      const VerificationMeta('isPreset');
  @override
  late final GeneratedColumn<bool> isPreset = GeneratedColumn<bool>(
      'is_preset', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_preset" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isEffectiveMeta =
      const VerificationMeta('isEffective');
  @override
  late final GeneratedColumn<bool> isEffective = GeneratedColumn<bool>(
      'is_effective', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_effective" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, emoji, color, isPreset, isEffective, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_labels';
  @override
  VerificationContext validateIntegrity(Insertable<UserLabel> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
          _emojiMeta, emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta));
    } else if (isInserting) {
      context.missing(_emojiMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('is_preset')) {
      context.handle(_isPresetMeta,
          isPreset.isAcceptableOrUnknown(data['is_preset']!, _isPresetMeta));
    }
    if (data.containsKey('is_effective')) {
      context.handle(
          _isEffectiveMeta,
          isEffective.isAcceptableOrUnknown(
              data['is_effective']!, _isEffectiveMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserLabel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserLabel(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      emoji: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}emoji'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color'])!,
      isPreset: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_preset'])!,
      isEffective: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_effective'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $UserLabelsTable createAlias(String alias) {
    return $UserLabelsTable(attachedDatabase, alias);
  }
}

class UserLabel extends DataClass implements Insertable<UserLabel> {
  final int id;
  final String name;
  final String emoji;
  final int color;
  final bool isPreset;
  final bool isEffective;
  final int sortOrder;
  const UserLabel(
      {required this.id,
      required this.name,
      required this.emoji,
      required this.color,
      required this.isPreset,
      required this.isEffective,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['emoji'] = Variable<String>(emoji);
    map['color'] = Variable<int>(color);
    map['is_preset'] = Variable<bool>(isPreset);
    map['is_effective'] = Variable<bool>(isEffective);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  UserLabelsCompanion toCompanion(bool nullToAbsent) {
    return UserLabelsCompanion(
      id: Value(id),
      name: Value(name),
      emoji: Value(emoji),
      color: Value(color),
      isPreset: Value(isPreset),
      isEffective: Value(isEffective),
      sortOrder: Value(sortOrder),
    );
  }

  factory UserLabel.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserLabel(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      emoji: serializer.fromJson<String>(json['emoji']),
      color: serializer.fromJson<int>(json['color']),
      isPreset: serializer.fromJson<bool>(json['isPreset']),
      isEffective: serializer.fromJson<bool>(json['isEffective']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'emoji': serializer.toJson<String>(emoji),
      'color': serializer.toJson<int>(color),
      'isPreset': serializer.toJson<bool>(isPreset),
      'isEffective': serializer.toJson<bool>(isEffective),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  UserLabel copyWith(
          {int? id,
          String? name,
          String? emoji,
          int? color,
          bool? isPreset,
          bool? isEffective,
          int? sortOrder}) =>
      UserLabel(
        id: id ?? this.id,
        name: name ?? this.name,
        emoji: emoji ?? this.emoji,
        color: color ?? this.color,
        isPreset: isPreset ?? this.isPreset,
        isEffective: isEffective ?? this.isEffective,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  UserLabel copyWithCompanion(UserLabelsCompanion data) {
    return UserLabel(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      color: data.color.present ? data.color.value : this.color,
      isPreset: data.isPreset.present ? data.isPreset.value : this.isPreset,
      isEffective:
          data.isEffective.present ? data.isEffective.value : this.isEffective,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserLabel(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('color: $color, ')
          ..write('isPreset: $isPreset, ')
          ..write('isEffective: $isEffective, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, emoji, color, isPreset, isEffective, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserLabel &&
          other.id == this.id &&
          other.name == this.name &&
          other.emoji == this.emoji &&
          other.color == this.color &&
          other.isPreset == this.isPreset &&
          other.isEffective == this.isEffective &&
          other.sortOrder == this.sortOrder);
}

class UserLabelsCompanion extends UpdateCompanion<UserLabel> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> emoji;
  final Value<int> color;
  final Value<bool> isPreset;
  final Value<bool> isEffective;
  final Value<int> sortOrder;
  const UserLabelsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.emoji = const Value.absent(),
    this.color = const Value.absent(),
    this.isPreset = const Value.absent(),
    this.isEffective = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  UserLabelsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String emoji,
    required int color,
    this.isPreset = const Value.absent(),
    this.isEffective = const Value.absent(),
    this.sortOrder = const Value.absent(),
  })  : name = Value(name),
        emoji = Value(emoji),
        color = Value(color);
  static Insertable<UserLabel> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? emoji,
    Expression<int>? color,
    Expression<bool>? isPreset,
    Expression<bool>? isEffective,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (emoji != null) 'emoji': emoji,
      if (color != null) 'color': color,
      if (isPreset != null) 'is_preset': isPreset,
      if (isEffective != null) 'is_effective': isEffective,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  UserLabelsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? emoji,
      Value<int>? color,
      Value<bool>? isPreset,
      Value<bool>? isEffective,
      Value<int>? sortOrder}) {
    return UserLabelsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      isPreset: isPreset ?? this.isPreset,
      isEffective: isEffective ?? this.isEffective,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (isPreset.present) {
      map['is_preset'] = Variable<bool>(isPreset.value);
    }
    if (isEffective.present) {
      map['is_effective'] = Variable<bool>(isEffective.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserLabelsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('color: $color, ')
          ..write('isPreset: $isPreset, ')
          ..write('isEffective: $isEffective, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $RecordLabelMappingsTable extends RecordLabelMappings
    with TableInfo<$RecordLabelMappingsTable, RecordLabelMapping> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecordLabelMappingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _recordIdMeta =
      const VerificationMeta('recordId');
  @override
  late final GeneratedColumn<int> recordId = GeneratedColumn<int>(
      'record_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES app_usage_records (id)'));
  static const VerificationMeta _labelIdMeta =
      const VerificationMeta('labelId');
  @override
  late final GeneratedColumn<int> labelId = GeneratedColumn<int>(
      'label_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES user_labels (id)'));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _taggedAtMeta =
      const VerificationMeta('taggedAt');
  @override
  late final GeneratedColumn<DateTime> taggedAt = GeneratedColumn<DateTime>(
      'tagged_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, recordId, labelId, note, taggedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'record_label_mappings';
  @override
  VerificationContext validateIntegrity(Insertable<RecordLabelMapping> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('record_id')) {
      context.handle(_recordIdMeta,
          recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta));
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('label_id')) {
      context.handle(_labelIdMeta,
          labelId.isAcceptableOrUnknown(data['label_id']!, _labelIdMeta));
    } else if (isInserting) {
      context.missing(_labelIdMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('tagged_at')) {
      context.handle(_taggedAtMeta,
          taggedAt.isAcceptableOrUnknown(data['tagged_at']!, _taggedAtMeta));
    } else if (isInserting) {
      context.missing(_taggedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecordLabelMapping map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecordLabelMapping(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      recordId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}record_id'])!,
      labelId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}label_id'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      taggedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}tagged_at'])!,
    );
  }

  @override
  $RecordLabelMappingsTable createAlias(String alias) {
    return $RecordLabelMappingsTable(attachedDatabase, alias);
  }
}

class RecordLabelMapping extends DataClass
    implements Insertable<RecordLabelMapping> {
  final int id;
  final int recordId;
  final int labelId;
  final String? note;
  final DateTime taggedAt;
  const RecordLabelMapping(
      {required this.id,
      required this.recordId,
      required this.labelId,
      this.note,
      required this.taggedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['record_id'] = Variable<int>(recordId);
    map['label_id'] = Variable<int>(labelId);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['tagged_at'] = Variable<DateTime>(taggedAt);
    return map;
  }

  RecordLabelMappingsCompanion toCompanion(bool nullToAbsent) {
    return RecordLabelMappingsCompanion(
      id: Value(id),
      recordId: Value(recordId),
      labelId: Value(labelId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      taggedAt: Value(taggedAt),
    );
  }

  factory RecordLabelMapping.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecordLabelMapping(
      id: serializer.fromJson<int>(json['id']),
      recordId: serializer.fromJson<int>(json['recordId']),
      labelId: serializer.fromJson<int>(json['labelId']),
      note: serializer.fromJson<String?>(json['note']),
      taggedAt: serializer.fromJson<DateTime>(json['taggedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recordId': serializer.toJson<int>(recordId),
      'labelId': serializer.toJson<int>(labelId),
      'note': serializer.toJson<String?>(note),
      'taggedAt': serializer.toJson<DateTime>(taggedAt),
    };
  }

  RecordLabelMapping copyWith(
          {int? id,
          int? recordId,
          int? labelId,
          Value<String?> note = const Value.absent(),
          DateTime? taggedAt}) =>
      RecordLabelMapping(
        id: id ?? this.id,
        recordId: recordId ?? this.recordId,
        labelId: labelId ?? this.labelId,
        note: note.present ? note.value : this.note,
        taggedAt: taggedAt ?? this.taggedAt,
      );
  RecordLabelMapping copyWithCompanion(RecordLabelMappingsCompanion data) {
    return RecordLabelMapping(
      id: data.id.present ? data.id.value : this.id,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      labelId: data.labelId.present ? data.labelId.value : this.labelId,
      note: data.note.present ? data.note.value : this.note,
      taggedAt: data.taggedAt.present ? data.taggedAt.value : this.taggedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecordLabelMapping(')
          ..write('id: $id, ')
          ..write('recordId: $recordId, ')
          ..write('labelId: $labelId, ')
          ..write('note: $note, ')
          ..write('taggedAt: $taggedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, recordId, labelId, note, taggedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecordLabelMapping &&
          other.id == this.id &&
          other.recordId == this.recordId &&
          other.labelId == this.labelId &&
          other.note == this.note &&
          other.taggedAt == this.taggedAt);
}

class RecordLabelMappingsCompanion extends UpdateCompanion<RecordLabelMapping> {
  final Value<int> id;
  final Value<int> recordId;
  final Value<int> labelId;
  final Value<String?> note;
  final Value<DateTime> taggedAt;
  const RecordLabelMappingsCompanion({
    this.id = const Value.absent(),
    this.recordId = const Value.absent(),
    this.labelId = const Value.absent(),
    this.note = const Value.absent(),
    this.taggedAt = const Value.absent(),
  });
  RecordLabelMappingsCompanion.insert({
    this.id = const Value.absent(),
    required int recordId,
    required int labelId,
    this.note = const Value.absent(),
    required DateTime taggedAt,
  })  : recordId = Value(recordId),
        labelId = Value(labelId),
        taggedAt = Value(taggedAt);
  static Insertable<RecordLabelMapping> custom({
    Expression<int>? id,
    Expression<int>? recordId,
    Expression<int>? labelId,
    Expression<String>? note,
    Expression<DateTime>? taggedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recordId != null) 'record_id': recordId,
      if (labelId != null) 'label_id': labelId,
      if (note != null) 'note': note,
      if (taggedAt != null) 'tagged_at': taggedAt,
    });
  }

  RecordLabelMappingsCompanion copyWith(
      {Value<int>? id,
      Value<int>? recordId,
      Value<int>? labelId,
      Value<String?>? note,
      Value<DateTime>? taggedAt}) {
    return RecordLabelMappingsCompanion(
      id: id ?? this.id,
      recordId: recordId ?? this.recordId,
      labelId: labelId ?? this.labelId,
      note: note ?? this.note,
      taggedAt: taggedAt ?? this.taggedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<int>(recordId.value);
    }
    if (labelId.present) {
      map['label_id'] = Variable<int>(labelId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (taggedAt.present) {
      map['tagged_at'] = Variable<DateTime>(taggedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecordLabelMappingsCompanion(')
          ..write('id: $id, ')
          ..write('recordId: $recordId, ')
          ..write('labelId: $labelId, ')
          ..write('note: $note, ')
          ..write('taggedAt: $taggedAt')
          ..write(')'))
        .toString();
  }
}

class $DailyStatsTable extends DailyStats
    with TableInfo<$DailyStatsTable, DailyStat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _totalScreenTimeMeta =
      const VerificationMeta('totalScreenTime');
  @override
  late final GeneratedColumn<int> totalScreenTime = GeneratedColumn<int>(
      'total_screen_time', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _effectiveTimeMeta =
      const VerificationMeta('effectiveTime');
  @override
  late final GeneratedColumn<int> effectiveTime = GeneratedColumn<int>(
      'effective_time', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _entertainTimeMeta =
      const VerificationMeta('entertainTime');
  @override
  late final GeneratedColumn<int> entertainTime = GeneratedColumn<int>(
      'entertain_time', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _unlabeledTimeMeta =
      const VerificationMeta('unlabeledTime');
  @override
  late final GeneratedColumn<int> unlabeledTime = GeneratedColumn<int>(
      'unlabeled_time', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _appCountMeta =
      const VerificationMeta('appCount');
  @override
  late final GeneratedColumn<int> appCount = GeneratedColumn<int>(
      'app_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _totalLaunchCountMeta =
      const VerificationMeta('totalLaunchCount');
  @override
  late final GeneratedColumn<int> totalLaunchCount = GeneratedColumn<int>(
      'total_launch_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        date,
        totalScreenTime,
        effectiveTime,
        entertainTime,
        unlabeledTime,
        appCount,
        totalLaunchCount,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_stats';
  @override
  VerificationContext validateIntegrity(Insertable<DailyStat> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('total_screen_time')) {
      context.handle(
          _totalScreenTimeMeta,
          totalScreenTime.isAcceptableOrUnknown(
              data['total_screen_time']!, _totalScreenTimeMeta));
    } else if (isInserting) {
      context.missing(_totalScreenTimeMeta);
    }
    if (data.containsKey('effective_time')) {
      context.handle(
          _effectiveTimeMeta,
          effectiveTime.isAcceptableOrUnknown(
              data['effective_time']!, _effectiveTimeMeta));
    } else if (isInserting) {
      context.missing(_effectiveTimeMeta);
    }
    if (data.containsKey('entertain_time')) {
      context.handle(
          _entertainTimeMeta,
          entertainTime.isAcceptableOrUnknown(
              data['entertain_time']!, _entertainTimeMeta));
    } else if (isInserting) {
      context.missing(_entertainTimeMeta);
    }
    if (data.containsKey('unlabeled_time')) {
      context.handle(
          _unlabeledTimeMeta,
          unlabeledTime.isAcceptableOrUnknown(
              data['unlabeled_time']!, _unlabeledTimeMeta));
    } else if (isInserting) {
      context.missing(_unlabeledTimeMeta);
    }
    if (data.containsKey('app_count')) {
      context.handle(_appCountMeta,
          appCount.isAcceptableOrUnknown(data['app_count']!, _appCountMeta));
    } else if (isInserting) {
      context.missing(_appCountMeta);
    }
    if (data.containsKey('total_launch_count')) {
      context.handle(
          _totalLaunchCountMeta,
          totalLaunchCount.isAcceptableOrUnknown(
              data['total_launch_count']!, _totalLaunchCountMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyStat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyStat(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      totalScreenTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_screen_time'])!,
      effectiveTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}effective_time'])!,
      entertainTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}entertain_time'])!,
      unlabeledTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unlabeled_time'])!,
      appCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}app_count'])!,
      totalLaunchCount: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}total_launch_count'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DailyStatsTable createAlias(String alias) {
    return $DailyStatsTable(attachedDatabase, alias);
  }
}

class DailyStat extends DataClass implements Insertable<DailyStat> {
  final int id;
  final DateTime date;
  final int totalScreenTime;
  final int effectiveTime;
  final int entertainTime;
  final int unlabeledTime;
  final int appCount;
  final int totalLaunchCount;
  final DateTime updatedAt;
  const DailyStat(
      {required this.id,
      required this.date,
      required this.totalScreenTime,
      required this.effectiveTime,
      required this.entertainTime,
      required this.unlabeledTime,
      required this.appCount,
      required this.totalLaunchCount,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['total_screen_time'] = Variable<int>(totalScreenTime);
    map['effective_time'] = Variable<int>(effectiveTime);
    map['entertain_time'] = Variable<int>(entertainTime);
    map['unlabeled_time'] = Variable<int>(unlabeledTime);
    map['app_count'] = Variable<int>(appCount);
    map['total_launch_count'] = Variable<int>(totalLaunchCount);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DailyStatsCompanion toCompanion(bool nullToAbsent) {
    return DailyStatsCompanion(
      id: Value(id),
      date: Value(date),
      totalScreenTime: Value(totalScreenTime),
      effectiveTime: Value(effectiveTime),
      entertainTime: Value(entertainTime),
      unlabeledTime: Value(unlabeledTime),
      appCount: Value(appCount),
      totalLaunchCount: Value(totalLaunchCount),
      updatedAt: Value(updatedAt),
    );
  }

  factory DailyStat.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyStat(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      totalScreenTime: serializer.fromJson<int>(json['totalScreenTime']),
      effectiveTime: serializer.fromJson<int>(json['effectiveTime']),
      entertainTime: serializer.fromJson<int>(json['entertainTime']),
      unlabeledTime: serializer.fromJson<int>(json['unlabeledTime']),
      appCount: serializer.fromJson<int>(json['appCount']),
      totalLaunchCount: serializer.fromJson<int>(json['totalLaunchCount']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'totalScreenTime': serializer.toJson<int>(totalScreenTime),
      'effectiveTime': serializer.toJson<int>(effectiveTime),
      'entertainTime': serializer.toJson<int>(entertainTime),
      'unlabeledTime': serializer.toJson<int>(unlabeledTime),
      'appCount': serializer.toJson<int>(appCount),
      'totalLaunchCount': serializer.toJson<int>(totalLaunchCount),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DailyStat copyWith(
          {int? id,
          DateTime? date,
          int? totalScreenTime,
          int? effectiveTime,
          int? entertainTime,
          int? unlabeledTime,
          int? appCount,
          int? totalLaunchCount,
          DateTime? updatedAt}) =>
      DailyStat(
        id: id ?? this.id,
        date: date ?? this.date,
        totalScreenTime: totalScreenTime ?? this.totalScreenTime,
        effectiveTime: effectiveTime ?? this.effectiveTime,
        entertainTime: entertainTime ?? this.entertainTime,
        unlabeledTime: unlabeledTime ?? this.unlabeledTime,
        appCount: appCount ?? this.appCount,
        totalLaunchCount: totalLaunchCount ?? this.totalLaunchCount,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DailyStat copyWithCompanion(DailyStatsCompanion data) {
    return DailyStat(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      totalScreenTime: data.totalScreenTime.present
          ? data.totalScreenTime.value
          : this.totalScreenTime,
      effectiveTime: data.effectiveTime.present
          ? data.effectiveTime.value
          : this.effectiveTime,
      entertainTime: data.entertainTime.present
          ? data.entertainTime.value
          : this.entertainTime,
      unlabeledTime: data.unlabeledTime.present
          ? data.unlabeledTime.value
          : this.unlabeledTime,
      appCount: data.appCount.present ? data.appCount.value : this.appCount,
      totalLaunchCount: data.totalLaunchCount.present
          ? data.totalLaunchCount.value
          : this.totalLaunchCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyStat(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('totalScreenTime: $totalScreenTime, ')
          ..write('effectiveTime: $effectiveTime, ')
          ..write('entertainTime: $entertainTime, ')
          ..write('unlabeledTime: $unlabeledTime, ')
          ..write('appCount: $appCount, ')
          ..write('totalLaunchCount: $totalLaunchCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, totalScreenTime, effectiveTime,
      entertainTime, unlabeledTime, appCount, totalLaunchCount, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyStat &&
          other.id == this.id &&
          other.date == this.date &&
          other.totalScreenTime == this.totalScreenTime &&
          other.effectiveTime == this.effectiveTime &&
          other.entertainTime == this.entertainTime &&
          other.unlabeledTime == this.unlabeledTime &&
          other.appCount == this.appCount &&
          other.totalLaunchCount == this.totalLaunchCount &&
          other.updatedAt == this.updatedAt);
}

class DailyStatsCompanion extends UpdateCompanion<DailyStat> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<int> totalScreenTime;
  final Value<int> effectiveTime;
  final Value<int> entertainTime;
  final Value<int> unlabeledTime;
  final Value<int> appCount;
  final Value<int> totalLaunchCount;
  final Value<DateTime> updatedAt;
  const DailyStatsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.totalScreenTime = const Value.absent(),
    this.effectiveTime = const Value.absent(),
    this.entertainTime = const Value.absent(),
    this.unlabeledTime = const Value.absent(),
    this.appCount = const Value.absent(),
    this.totalLaunchCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DailyStatsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required int totalScreenTime,
    required int effectiveTime,
    required int entertainTime,
    required int unlabeledTime,
    required int appCount,
    this.totalLaunchCount = const Value.absent(),
    required DateTime updatedAt,
  })  : date = Value(date),
        totalScreenTime = Value(totalScreenTime),
        effectiveTime = Value(effectiveTime),
        entertainTime = Value(entertainTime),
        unlabeledTime = Value(unlabeledTime),
        appCount = Value(appCount),
        updatedAt = Value(updatedAt);
  static Insertable<DailyStat> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? totalScreenTime,
    Expression<int>? effectiveTime,
    Expression<int>? entertainTime,
    Expression<int>? unlabeledTime,
    Expression<int>? appCount,
    Expression<int>? totalLaunchCount,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (totalScreenTime != null) 'total_screen_time': totalScreenTime,
      if (effectiveTime != null) 'effective_time': effectiveTime,
      if (entertainTime != null) 'entertain_time': entertainTime,
      if (unlabeledTime != null) 'unlabeled_time': unlabeledTime,
      if (appCount != null) 'app_count': appCount,
      if (totalLaunchCount != null) 'total_launch_count': totalLaunchCount,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DailyStatsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? date,
      Value<int>? totalScreenTime,
      Value<int>? effectiveTime,
      Value<int>? entertainTime,
      Value<int>? unlabeledTime,
      Value<int>? appCount,
      Value<int>? totalLaunchCount,
      Value<DateTime>? updatedAt}) {
    return DailyStatsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      totalScreenTime: totalScreenTime ?? this.totalScreenTime,
      effectiveTime: effectiveTime ?? this.effectiveTime,
      entertainTime: entertainTime ?? this.entertainTime,
      unlabeledTime: unlabeledTime ?? this.unlabeledTime,
      appCount: appCount ?? this.appCount,
      totalLaunchCount: totalLaunchCount ?? this.totalLaunchCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (totalScreenTime.present) {
      map['total_screen_time'] = Variable<int>(totalScreenTime.value);
    }
    if (effectiveTime.present) {
      map['effective_time'] = Variable<int>(effectiveTime.value);
    }
    if (entertainTime.present) {
      map['entertain_time'] = Variable<int>(entertainTime.value);
    }
    if (unlabeledTime.present) {
      map['unlabeled_time'] = Variable<int>(unlabeledTime.value);
    }
    if (appCount.present) {
      map['app_count'] = Variable<int>(appCount.value);
    }
    if (totalLaunchCount.present) {
      map['total_launch_count'] = Variable<int>(totalLaunchCount.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyStatsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('totalScreenTime: $totalScreenTime, ')
          ..write('effectiveTime: $effectiveTime, ')
          ..write('entertainTime: $entertainTime, ')
          ..write('unlabeledTime: $unlabeledTime, ')
          ..write('appCount: $appCount, ')
          ..write('totalLaunchCount: $totalLaunchCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PinnedLabelsTable extends PinnedLabels
    with TableInfo<$PinnedLabelsTable, PinnedLabel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PinnedLabelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _packageNameMeta =
      const VerificationMeta('packageName');
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
      'package_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelIdMeta =
      const VerificationMeta('labelId');
  @override
  late final GeneratedColumn<int> labelId = GeneratedColumn<int>(
      'label_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES user_labels (id)'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [packageName, labelId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pinned_labels';
  @override
  VerificationContext validateIntegrity(Insertable<PinnedLabel> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('package_name')) {
      context.handle(
          _packageNameMeta,
          packageName.isAcceptableOrUnknown(
              data['package_name']!, _packageNameMeta));
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('label_id')) {
      context.handle(_labelIdMeta,
          labelId.isAcceptableOrUnknown(data['label_id']!, _labelIdMeta));
    } else if (isInserting) {
      context.missing(_labelIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {packageName};
  @override
  PinnedLabel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PinnedLabel(
      packageName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}package_name'])!,
      labelId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}label_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PinnedLabelsTable createAlias(String alias) {
    return $PinnedLabelsTable(attachedDatabase, alias);
  }
}

class PinnedLabel extends DataClass implements Insertable<PinnedLabel> {
  final String packageName;
  final int labelId;
  final DateTime createdAt;
  const PinnedLabel(
      {required this.packageName,
      required this.labelId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['package_name'] = Variable<String>(packageName);
    map['label_id'] = Variable<int>(labelId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PinnedLabelsCompanion toCompanion(bool nullToAbsent) {
    return PinnedLabelsCompanion(
      packageName: Value(packageName),
      labelId: Value(labelId),
      createdAt: Value(createdAt),
    );
  }

  factory PinnedLabel.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PinnedLabel(
      packageName: serializer.fromJson<String>(json['packageName']),
      labelId: serializer.fromJson<int>(json['labelId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'packageName': serializer.toJson<String>(packageName),
      'labelId': serializer.toJson<int>(labelId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PinnedLabel copyWith(
          {String? packageName, int? labelId, DateTime? createdAt}) =>
      PinnedLabel(
        packageName: packageName ?? this.packageName,
        labelId: labelId ?? this.labelId,
        createdAt: createdAt ?? this.createdAt,
      );
  PinnedLabel copyWithCompanion(PinnedLabelsCompanion data) {
    return PinnedLabel(
      packageName:
          data.packageName.present ? data.packageName.value : this.packageName,
      labelId: data.labelId.present ? data.labelId.value : this.labelId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PinnedLabel(')
          ..write('packageName: $packageName, ')
          ..write('labelId: $labelId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(packageName, labelId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PinnedLabel &&
          other.packageName == this.packageName &&
          other.labelId == this.labelId &&
          other.createdAt == this.createdAt);
}

class PinnedLabelsCompanion extends UpdateCompanion<PinnedLabel> {
  final Value<String> packageName;
  final Value<int> labelId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PinnedLabelsCompanion({
    this.packageName = const Value.absent(),
    this.labelId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PinnedLabelsCompanion.insert({
    required String packageName,
    required int labelId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : packageName = Value(packageName),
        labelId = Value(labelId),
        createdAt = Value(createdAt);
  static Insertable<PinnedLabel> custom({
    Expression<String>? packageName,
    Expression<int>? labelId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (packageName != null) 'package_name': packageName,
      if (labelId != null) 'label_id': labelId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PinnedLabelsCompanion copyWith(
      {Value<String>? packageName,
      Value<int>? labelId,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return PinnedLabelsCompanion(
      packageName: packageName ?? this.packageName,
      labelId: labelId ?? this.labelId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (labelId.present) {
      map['label_id'] = Variable<int>(labelId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PinnedLabelsCompanion(')
          ..write('packageName: $packageName, ')
          ..write('labelId: $labelId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalTemplatesTable extends GoalTemplates
    with TableInfo<$GoalTemplatesTable, GoalTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _plannedDurationMeta =
      const VerificationMeta('plannedDuration');
  @override
  late final GeneratedColumn<int> plannedDuration = GeneratedColumn<int>(
      'planned_duration', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _usageCountMeta =
      const VerificationMeta('usageCount');
  @override
  late final GeneratedColumn<int> usageCount = GeneratedColumn<int>(
      'usage_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, plannedDuration, notes, usageCount, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal_templates';
  @override
  VerificationContext validateIntegrity(Insertable<GoalTemplate> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('planned_duration')) {
      context.handle(
          _plannedDurationMeta,
          plannedDuration.isAcceptableOrUnknown(
              data['planned_duration']!, _plannedDurationMeta));
    } else if (isInserting) {
      context.missing(_plannedDurationMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('usage_count')) {
      context.handle(
          _usageCountMeta,
          usageCount.isAcceptableOrUnknown(
              data['usage_count']!, _usageCountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalTemplate(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      plannedDuration: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}planned_duration'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      usageCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}usage_count'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $GoalTemplatesTable createAlias(String alias) {
    return $GoalTemplatesTable(attachedDatabase, alias);
  }
}

class GoalTemplate extends DataClass implements Insertable<GoalTemplate> {
  final int id;
  final String title;
  final int plannedDuration;
  final String? notes;
  final int usageCount;
  final DateTime createdAt;
  const GoalTemplate(
      {required this.id,
      required this.title,
      required this.plannedDuration,
      this.notes,
      required this.usageCount,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['planned_duration'] = Variable<int>(plannedDuration);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['usage_count'] = Variable<int>(usageCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GoalTemplatesCompanion toCompanion(bool nullToAbsent) {
    return GoalTemplatesCompanion(
      id: Value(id),
      title: Value(title),
      plannedDuration: Value(plannedDuration),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      usageCount: Value(usageCount),
      createdAt: Value(createdAt),
    );
  }

  factory GoalTemplate.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalTemplate(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      plannedDuration: serializer.fromJson<int>(json['plannedDuration']),
      notes: serializer.fromJson<String?>(json['notes']),
      usageCount: serializer.fromJson<int>(json['usageCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'plannedDuration': serializer.toJson<int>(plannedDuration),
      'notes': serializer.toJson<String?>(notes),
      'usageCount': serializer.toJson<int>(usageCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GoalTemplate copyWith(
          {int? id,
          String? title,
          int? plannedDuration,
          Value<String?> notes = const Value.absent(),
          int? usageCount,
          DateTime? createdAt}) =>
      GoalTemplate(
        id: id ?? this.id,
        title: title ?? this.title,
        plannedDuration: plannedDuration ?? this.plannedDuration,
        notes: notes.present ? notes.value : this.notes,
        usageCount: usageCount ?? this.usageCount,
        createdAt: createdAt ?? this.createdAt,
      );
  GoalTemplate copyWithCompanion(GoalTemplatesCompanion data) {
    return GoalTemplate(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      plannedDuration: data.plannedDuration.present
          ? data.plannedDuration.value
          : this.plannedDuration,
      notes: data.notes.present ? data.notes.value : this.notes,
      usageCount:
          data.usageCount.present ? data.usageCount.value : this.usageCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalTemplate(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('plannedDuration: $plannedDuration, ')
          ..write('notes: $notes, ')
          ..write('usageCount: $usageCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, plannedDuration, notes, usageCount, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalTemplate &&
          other.id == this.id &&
          other.title == this.title &&
          other.plannedDuration == this.plannedDuration &&
          other.notes == this.notes &&
          other.usageCount == this.usageCount &&
          other.createdAt == this.createdAt);
}

class GoalTemplatesCompanion extends UpdateCompanion<GoalTemplate> {
  final Value<int> id;
  final Value<String> title;
  final Value<int> plannedDuration;
  final Value<String?> notes;
  final Value<int> usageCount;
  final Value<DateTime> createdAt;
  const GoalTemplatesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.plannedDuration = const Value.absent(),
    this.notes = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  GoalTemplatesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required int plannedDuration,
    this.notes = const Value.absent(),
    this.usageCount = const Value.absent(),
    required DateTime createdAt,
  })  : title = Value(title),
        plannedDuration = Value(plannedDuration),
        createdAt = Value(createdAt);
  static Insertable<GoalTemplate> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<int>? plannedDuration,
    Expression<String>? notes,
    Expression<int>? usageCount,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (plannedDuration != null) 'planned_duration': plannedDuration,
      if (notes != null) 'notes': notes,
      if (usageCount != null) 'usage_count': usageCount,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  GoalTemplatesCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<int>? plannedDuration,
      Value<String?>? notes,
      Value<int>? usageCount,
      Value<DateTime>? createdAt}) {
    return GoalTemplatesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      plannedDuration: plannedDuration ?? this.plannedDuration,
      notes: notes ?? this.notes,
      usageCount: usageCount ?? this.usageCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (plannedDuration.present) {
      map['planned_duration'] = Variable<int>(plannedDuration.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (usageCount.present) {
      map['usage_count'] = Variable<int>(usageCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('plannedDuration: $plannedDuration, ')
          ..write('notes: $notes, ')
          ..write('usageCount: $usageCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $AppUsageRecordsTable appUsageRecords =
      $AppUsageRecordsTable(this);
  late final $UserLabelsTable userLabels = $UserLabelsTable(this);
  late final $RecordLabelMappingsTable recordLabelMappings =
      $RecordLabelMappingsTable(this);
  late final $DailyStatsTable dailyStats = $DailyStatsTable(this);
  late final $PinnedLabelsTable pinnedLabels = $PinnedLabelsTable(this);
  late final $GoalTemplatesTable goalTemplates = $GoalTemplatesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        goals,
        appUsageRecords,
        userLabels,
        recordLabelMappings,
        dailyStats,
        pinnedLabels,
        goalTemplates
      ];
}

typedef $$GoalsTableCreateCompanionBuilder = GoalsCompanion Function({
  Value<int> id,
  required String title,
  Value<String?> description,
  required int plannedDuration,
  Value<int?> actualDuration,
  required int startTime,
  Value<int?> endTime,
  required String status,
  Value<bool?> completed,
  Value<String?> userNote,
  Value<String?> aiReviewText,
  Value<int?> aiReviewFeedback,
  required DateTime createdAt,
});
typedef $$GoalsTableUpdateCompanionBuilder = GoalsCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String?> description,
  Value<int> plannedDuration,
  Value<int?> actualDuration,
  Value<int> startTime,
  Value<int?> endTime,
  Value<String> status,
  Value<bool?> completed,
  Value<String?> userNote,
  Value<String?> aiReviewText,
  Value<int?> aiReviewFeedback,
  Value<DateTime> createdAt,
});

class $$GoalsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GoalsTable,
    Goal,
    $$GoalsTableFilterComposer,
    $$GoalsTableOrderingComposer,
    $$GoalsTableCreateCompanionBuilder,
    $$GoalsTableUpdateCompanionBuilder> {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$GoalsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$GoalsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> plannedDuration = const Value.absent(),
            Value<int?> actualDuration = const Value.absent(),
            Value<int> startTime = const Value.absent(),
            Value<int?> endTime = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<bool?> completed = const Value.absent(),
            Value<String?> userNote = const Value.absent(),
            Value<String?> aiReviewText = const Value.absent(),
            Value<int?> aiReviewFeedback = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              GoalsCompanion(
            id: id,
            title: title,
            description: description,
            plannedDuration: plannedDuration,
            actualDuration: actualDuration,
            startTime: startTime,
            endTime: endTime,
            status: status,
            completed: completed,
            userNote: userNote,
            aiReviewText: aiReviewText,
            aiReviewFeedback: aiReviewFeedback,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            Value<String?> description = const Value.absent(),
            required int plannedDuration,
            Value<int?> actualDuration = const Value.absent(),
            required int startTime,
            Value<int?> endTime = const Value.absent(),
            required String status,
            Value<bool?> completed = const Value.absent(),
            Value<String?> userNote = const Value.absent(),
            Value<String?> aiReviewText = const Value.absent(),
            Value<int?> aiReviewFeedback = const Value.absent(),
            required DateTime createdAt,
          }) =>
              GoalsCompanion.insert(
            id: id,
            title: title,
            description: description,
            plannedDuration: plannedDuration,
            actualDuration: actualDuration,
            startTime: startTime,
            endTime: endTime,
            status: status,
            completed: completed,
            userNote: userNote,
            aiReviewText: aiReviewText,
            aiReviewFeedback: aiReviewFeedback,
            createdAt: createdAt,
          ),
        ));
}

class $$GoalsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get plannedDuration => $state.composableBuilder(
      column: $state.table.plannedDuration,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get actualDuration => $state.composableBuilder(
      column: $state.table.actualDuration,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get startTime => $state.composableBuilder(
      column: $state.table.startTime,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get endTime => $state.composableBuilder(
      column: $state.table.endTime,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get completed => $state.composableBuilder(
      column: $state.table.completed,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get userNote => $state.composableBuilder(
      column: $state.table.userNote,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get aiReviewText => $state.composableBuilder(
      column: $state.table.aiReviewText,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get aiReviewFeedback => $state.composableBuilder(
      column: $state.table.aiReviewFeedback,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter appUsageRecordsRefs(
      ComposableFilter Function($$AppUsageRecordsTableFilterComposer f) f) {
    final $$AppUsageRecordsTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.appUsageRecords,
            getReferencedColumn: (t) => t.goalId,
            builder: (joinBuilder, parentComposers) =>
                $$AppUsageRecordsTableFilterComposer(ComposerState($state.db,
                    $state.db.appUsageRecords, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$GoalsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get plannedDuration => $state.composableBuilder(
      column: $state.table.plannedDuration,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get actualDuration => $state.composableBuilder(
      column: $state.table.actualDuration,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get startTime => $state.composableBuilder(
      column: $state.table.startTime,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get endTime => $state.composableBuilder(
      column: $state.table.endTime,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get completed => $state.composableBuilder(
      column: $state.table.completed,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get userNote => $state.composableBuilder(
      column: $state.table.userNote,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get aiReviewText => $state.composableBuilder(
      column: $state.table.aiReviewText,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get aiReviewFeedback => $state.composableBuilder(
      column: $state.table.aiReviewFeedback,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$AppUsageRecordsTableCreateCompanionBuilder = AppUsageRecordsCompanion
    Function({
  Value<int> id,
  required String packageName,
  required String appName,
  Value<String> appCategory,
  required int startTime,
  required int endTime,
  required int duration,
  required DateTime date,
  Value<int> launchCount,
  Value<int?> goalId,
});
typedef $$AppUsageRecordsTableUpdateCompanionBuilder = AppUsageRecordsCompanion
    Function({
  Value<int> id,
  Value<String> packageName,
  Value<String> appName,
  Value<String> appCategory,
  Value<int> startTime,
  Value<int> endTime,
  Value<int> duration,
  Value<DateTime> date,
  Value<int> launchCount,
  Value<int?> goalId,
});

class $$AppUsageRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppUsageRecordsTable,
    AppUsageRecord,
    $$AppUsageRecordsTableFilterComposer,
    $$AppUsageRecordsTableOrderingComposer,
    $$AppUsageRecordsTableCreateCompanionBuilder,
    $$AppUsageRecordsTableUpdateCompanionBuilder> {
  $$AppUsageRecordsTableTableManager(
      _$AppDatabase db, $AppUsageRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AppUsageRecordsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$AppUsageRecordsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> packageName = const Value.absent(),
            Value<String> appName = const Value.absent(),
            Value<String> appCategory = const Value.absent(),
            Value<int> startTime = const Value.absent(),
            Value<int> endTime = const Value.absent(),
            Value<int> duration = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<int> launchCount = const Value.absent(),
            Value<int?> goalId = const Value.absent(),
          }) =>
              AppUsageRecordsCompanion(
            id: id,
            packageName: packageName,
            appName: appName,
            appCategory: appCategory,
            startTime: startTime,
            endTime: endTime,
            duration: duration,
            date: date,
            launchCount: launchCount,
            goalId: goalId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String packageName,
            required String appName,
            Value<String> appCategory = const Value.absent(),
            required int startTime,
            required int endTime,
            required int duration,
            required DateTime date,
            Value<int> launchCount = const Value.absent(),
            Value<int?> goalId = const Value.absent(),
          }) =>
              AppUsageRecordsCompanion.insert(
            id: id,
            packageName: packageName,
            appName: appName,
            appCategory: appCategory,
            startTime: startTime,
            endTime: endTime,
            duration: duration,
            date: date,
            launchCount: launchCount,
            goalId: goalId,
          ),
        ));
}

class $$AppUsageRecordsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $AppUsageRecordsTable> {
  $$AppUsageRecordsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get packageName => $state.composableBuilder(
      column: $state.table.packageName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get appName => $state.composableBuilder(
      column: $state.table.appName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get appCategory => $state.composableBuilder(
      column: $state.table.appCategory,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get startTime => $state.composableBuilder(
      column: $state.table.startTime,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get endTime => $state.composableBuilder(
      column: $state.table.endTime,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get duration => $state.composableBuilder(
      column: $state.table.duration,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get launchCount => $state.composableBuilder(
      column: $state.table.launchCount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$GoalsTableFilterComposer get goalId {
    final $$GoalsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.goalId,
        referencedTable: $state.db.goals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$GoalsTableFilterComposer(
            ComposerState(
                $state.db, $state.db.goals, joinBuilder, parentComposers)));
    return composer;
  }

  ComposableFilter recordLabelMappingsRefs(
      ComposableFilter Function($$RecordLabelMappingsTableFilterComposer f) f) {
    final $$RecordLabelMappingsTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.recordLabelMappings,
            getReferencedColumn: (t) => t.recordId,
            builder: (joinBuilder, parentComposers) =>
                $$RecordLabelMappingsTableFilterComposer(ComposerState(
                    $state.db,
                    $state.db.recordLabelMappings,
                    joinBuilder,
                    parentComposers)));
    return f(composer);
  }
}

class $$AppUsageRecordsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $AppUsageRecordsTable> {
  $$AppUsageRecordsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get packageName => $state.composableBuilder(
      column: $state.table.packageName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get appName => $state.composableBuilder(
      column: $state.table.appName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get appCategory => $state.composableBuilder(
      column: $state.table.appCategory,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get startTime => $state.composableBuilder(
      column: $state.table.startTime,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get endTime => $state.composableBuilder(
      column: $state.table.endTime,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get duration => $state.composableBuilder(
      column: $state.table.duration,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get launchCount => $state.composableBuilder(
      column: $state.table.launchCount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$GoalsTableOrderingComposer get goalId {
    final $$GoalsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.goalId,
        referencedTable: $state.db.goals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$GoalsTableOrderingComposer(
            ComposerState(
                $state.db, $state.db.goals, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$UserLabelsTableCreateCompanionBuilder = UserLabelsCompanion Function({
  Value<int> id,
  required String name,
  required String emoji,
  required int color,
  Value<bool> isPreset,
  Value<bool> isEffective,
  Value<int> sortOrder,
});
typedef $$UserLabelsTableUpdateCompanionBuilder = UserLabelsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> emoji,
  Value<int> color,
  Value<bool> isPreset,
  Value<bool> isEffective,
  Value<int> sortOrder,
});

class $$UserLabelsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserLabelsTable,
    UserLabel,
    $$UserLabelsTableFilterComposer,
    $$UserLabelsTableOrderingComposer,
    $$UserLabelsTableCreateCompanionBuilder,
    $$UserLabelsTableUpdateCompanionBuilder> {
  $$UserLabelsTableTableManager(_$AppDatabase db, $UserLabelsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$UserLabelsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$UserLabelsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> emoji = const Value.absent(),
            Value<int> color = const Value.absent(),
            Value<bool> isPreset = const Value.absent(),
            Value<bool> isEffective = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
          }) =>
              UserLabelsCompanion(
            id: id,
            name: name,
            emoji: emoji,
            color: color,
            isPreset: isPreset,
            isEffective: isEffective,
            sortOrder: sortOrder,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String emoji,
            required int color,
            Value<bool> isPreset = const Value.absent(),
            Value<bool> isEffective = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
          }) =>
              UserLabelsCompanion.insert(
            id: id,
            name: name,
            emoji: emoji,
            color: color,
            isPreset: isPreset,
            isEffective: isEffective,
            sortOrder: sortOrder,
          ),
        ));
}

class $$UserLabelsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $UserLabelsTable> {
  $$UserLabelsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get emoji => $state.composableBuilder(
      column: $state.table.emoji,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isPreset => $state.composableBuilder(
      column: $state.table.isPreset,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isEffective => $state.composableBuilder(
      column: $state.table.isEffective,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get sortOrder => $state.composableBuilder(
      column: $state.table.sortOrder,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter recordLabelMappingsRefs(
      ComposableFilter Function($$RecordLabelMappingsTableFilterComposer f) f) {
    final $$RecordLabelMappingsTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.recordLabelMappings,
            getReferencedColumn: (t) => t.labelId,
            builder: (joinBuilder, parentComposers) =>
                $$RecordLabelMappingsTableFilterComposer(ComposerState(
                    $state.db,
                    $state.db.recordLabelMappings,
                    joinBuilder,
                    parentComposers)));
    return f(composer);
  }

  ComposableFilter pinnedLabelsRefs(
      ComposableFilter Function($$PinnedLabelsTableFilterComposer f) f) {
    final $$PinnedLabelsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.pinnedLabels,
        getReferencedColumn: (t) => t.labelId,
        builder: (joinBuilder, parentComposers) =>
            $$PinnedLabelsTableFilterComposer(ComposerState($state.db,
                $state.db.pinnedLabels, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$UserLabelsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $UserLabelsTable> {
  $$UserLabelsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get emoji => $state.composableBuilder(
      column: $state.table.emoji,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isPreset => $state.composableBuilder(
      column: $state.table.isPreset,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isEffective => $state.composableBuilder(
      column: $state.table.isEffective,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get sortOrder => $state.composableBuilder(
      column: $state.table.sortOrder,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$RecordLabelMappingsTableCreateCompanionBuilder
    = RecordLabelMappingsCompanion Function({
  Value<int> id,
  required int recordId,
  required int labelId,
  Value<String?> note,
  required DateTime taggedAt,
});
typedef $$RecordLabelMappingsTableUpdateCompanionBuilder
    = RecordLabelMappingsCompanion Function({
  Value<int> id,
  Value<int> recordId,
  Value<int> labelId,
  Value<String?> note,
  Value<DateTime> taggedAt,
});

class $$RecordLabelMappingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecordLabelMappingsTable,
    RecordLabelMapping,
    $$RecordLabelMappingsTableFilterComposer,
    $$RecordLabelMappingsTableOrderingComposer,
    $$RecordLabelMappingsTableCreateCompanionBuilder,
    $$RecordLabelMappingsTableUpdateCompanionBuilder> {
  $$RecordLabelMappingsTableTableManager(
      _$AppDatabase db, $RecordLabelMappingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$RecordLabelMappingsTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$RecordLabelMappingsTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> recordId = const Value.absent(),
            Value<int> labelId = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<DateTime> taggedAt = const Value.absent(),
          }) =>
              RecordLabelMappingsCompanion(
            id: id,
            recordId: recordId,
            labelId: labelId,
            note: note,
            taggedAt: taggedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int recordId,
            required int labelId,
            Value<String?> note = const Value.absent(),
            required DateTime taggedAt,
          }) =>
              RecordLabelMappingsCompanion.insert(
            id: id,
            recordId: recordId,
            labelId: labelId,
            note: note,
            taggedAt: taggedAt,
          ),
        ));
}

class $$RecordLabelMappingsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $RecordLabelMappingsTable> {
  $$RecordLabelMappingsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get note => $state.composableBuilder(
      column: $state.table.note,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get taggedAt => $state.composableBuilder(
      column: $state.table.taggedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$AppUsageRecordsTableFilterComposer get recordId {
    final $$AppUsageRecordsTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.recordId,
            referencedTable: $state.db.appUsageRecords,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$AppUsageRecordsTableFilterComposer(ComposerState($state.db,
                    $state.db.appUsageRecords, joinBuilder, parentComposers)));
    return composer;
  }

  $$UserLabelsTableFilterComposer get labelId {
    final $$UserLabelsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.labelId,
        referencedTable: $state.db.userLabels,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$UserLabelsTableFilterComposer(ComposerState($state.db,
                $state.db.userLabels, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$RecordLabelMappingsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $RecordLabelMappingsTable> {
  $$RecordLabelMappingsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get note => $state.composableBuilder(
      column: $state.table.note,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get taggedAt => $state.composableBuilder(
      column: $state.table.taggedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$AppUsageRecordsTableOrderingComposer get recordId {
    final $$AppUsageRecordsTableOrderingComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.recordId,
            referencedTable: $state.db.appUsageRecords,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$AppUsageRecordsTableOrderingComposer(ComposerState($state.db,
                    $state.db.appUsageRecords, joinBuilder, parentComposers)));
    return composer;
  }

  $$UserLabelsTableOrderingComposer get labelId {
    final $$UserLabelsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.labelId,
        referencedTable: $state.db.userLabels,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$UserLabelsTableOrderingComposer(ComposerState($state.db,
                $state.db.userLabels, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$DailyStatsTableCreateCompanionBuilder = DailyStatsCompanion Function({
  Value<int> id,
  required DateTime date,
  required int totalScreenTime,
  required int effectiveTime,
  required int entertainTime,
  required int unlabeledTime,
  required int appCount,
  Value<int> totalLaunchCount,
  required DateTime updatedAt,
});
typedef $$DailyStatsTableUpdateCompanionBuilder = DailyStatsCompanion Function({
  Value<int> id,
  Value<DateTime> date,
  Value<int> totalScreenTime,
  Value<int> effectiveTime,
  Value<int> entertainTime,
  Value<int> unlabeledTime,
  Value<int> appCount,
  Value<int> totalLaunchCount,
  Value<DateTime> updatedAt,
});

class $$DailyStatsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DailyStatsTable,
    DailyStat,
    $$DailyStatsTableFilterComposer,
    $$DailyStatsTableOrderingComposer,
    $$DailyStatsTableCreateCompanionBuilder,
    $$DailyStatsTableUpdateCompanionBuilder> {
  $$DailyStatsTableTableManager(_$AppDatabase db, $DailyStatsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$DailyStatsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$DailyStatsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<int> totalScreenTime = const Value.absent(),
            Value<int> effectiveTime = const Value.absent(),
            Value<int> entertainTime = const Value.absent(),
            Value<int> unlabeledTime = const Value.absent(),
            Value<int> appCount = const Value.absent(),
            Value<int> totalLaunchCount = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              DailyStatsCompanion(
            id: id,
            date: date,
            totalScreenTime: totalScreenTime,
            effectiveTime: effectiveTime,
            entertainTime: entertainTime,
            unlabeledTime: unlabeledTime,
            appCount: appCount,
            totalLaunchCount: totalLaunchCount,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime date,
            required int totalScreenTime,
            required int effectiveTime,
            required int entertainTime,
            required int unlabeledTime,
            required int appCount,
            Value<int> totalLaunchCount = const Value.absent(),
            required DateTime updatedAt,
          }) =>
              DailyStatsCompanion.insert(
            id: id,
            date: date,
            totalScreenTime: totalScreenTime,
            effectiveTime: effectiveTime,
            entertainTime: entertainTime,
            unlabeledTime: unlabeledTime,
            appCount: appCount,
            totalLaunchCount: totalLaunchCount,
            updatedAt: updatedAt,
          ),
        ));
}

class $$DailyStatsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $DailyStatsTable> {
  $$DailyStatsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get totalScreenTime => $state.composableBuilder(
      column: $state.table.totalScreenTime,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get effectiveTime => $state.composableBuilder(
      column: $state.table.effectiveTime,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get entertainTime => $state.composableBuilder(
      column: $state.table.entertainTime,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get unlabeledTime => $state.composableBuilder(
      column: $state.table.unlabeledTime,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get appCount => $state.composableBuilder(
      column: $state.table.appCount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get totalLaunchCount => $state.composableBuilder(
      column: $state.table.totalLaunchCount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$DailyStatsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $DailyStatsTable> {
  $$DailyStatsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get totalScreenTime => $state.composableBuilder(
      column: $state.table.totalScreenTime,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get effectiveTime => $state.composableBuilder(
      column: $state.table.effectiveTime,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get entertainTime => $state.composableBuilder(
      column: $state.table.entertainTime,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get unlabeledTime => $state.composableBuilder(
      column: $state.table.unlabeledTime,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get appCount => $state.composableBuilder(
      column: $state.table.appCount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get totalLaunchCount => $state.composableBuilder(
      column: $state.table.totalLaunchCount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$PinnedLabelsTableCreateCompanionBuilder = PinnedLabelsCompanion
    Function({
  required String packageName,
  required int labelId,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$PinnedLabelsTableUpdateCompanionBuilder = PinnedLabelsCompanion
    Function({
  Value<String> packageName,
  Value<int> labelId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$PinnedLabelsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PinnedLabelsTable,
    PinnedLabel,
    $$PinnedLabelsTableFilterComposer,
    $$PinnedLabelsTableOrderingComposer,
    $$PinnedLabelsTableCreateCompanionBuilder,
    $$PinnedLabelsTableUpdateCompanionBuilder> {
  $$PinnedLabelsTableTableManager(_$AppDatabase db, $PinnedLabelsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$PinnedLabelsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$PinnedLabelsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> packageName = const Value.absent(),
            Value<int> labelId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PinnedLabelsCompanion(
            packageName: packageName,
            labelId: labelId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String packageName,
            required int labelId,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PinnedLabelsCompanion.insert(
            packageName: packageName,
            labelId: labelId,
            createdAt: createdAt,
            rowid: rowid,
          ),
        ));
}

class $$PinnedLabelsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $PinnedLabelsTable> {
  $$PinnedLabelsTableFilterComposer(super.$state);
  ColumnFilters<String> get packageName => $state.composableBuilder(
      column: $state.table.packageName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$UserLabelsTableFilterComposer get labelId {
    final $$UserLabelsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.labelId,
        referencedTable: $state.db.userLabels,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$UserLabelsTableFilterComposer(ComposerState($state.db,
                $state.db.userLabels, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$PinnedLabelsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $PinnedLabelsTable> {
  $$PinnedLabelsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get packageName => $state.composableBuilder(
      column: $state.table.packageName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$UserLabelsTableOrderingComposer get labelId {
    final $$UserLabelsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.labelId,
        referencedTable: $state.db.userLabels,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$UserLabelsTableOrderingComposer(ComposerState($state.db,
                $state.db.userLabels, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$GoalTemplatesTableCreateCompanionBuilder = GoalTemplatesCompanion
    Function({
  Value<int> id,
  required String title,
  required int plannedDuration,
  Value<String?> notes,
  Value<int> usageCount,
  required DateTime createdAt,
});
typedef $$GoalTemplatesTableUpdateCompanionBuilder = GoalTemplatesCompanion
    Function({
  Value<int> id,
  Value<String> title,
  Value<int> plannedDuration,
  Value<String?> notes,
  Value<int> usageCount,
  Value<DateTime> createdAt,
});

class $$GoalTemplatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GoalTemplatesTable,
    GoalTemplate,
    $$GoalTemplatesTableFilterComposer,
    $$GoalTemplatesTableOrderingComposer,
    $$GoalTemplatesTableCreateCompanionBuilder,
    $$GoalTemplatesTableUpdateCompanionBuilder> {
  $$GoalTemplatesTableTableManager(_$AppDatabase db, $GoalTemplatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$GoalTemplatesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$GoalTemplatesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<int> plannedDuration = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> usageCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              GoalTemplatesCompanion(
            id: id,
            title: title,
            plannedDuration: plannedDuration,
            notes: notes,
            usageCount: usageCount,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            required int plannedDuration,
            Value<String?> notes = const Value.absent(),
            Value<int> usageCount = const Value.absent(),
            required DateTime createdAt,
          }) =>
              GoalTemplatesCompanion.insert(
            id: id,
            title: title,
            plannedDuration: plannedDuration,
            notes: notes,
            usageCount: usageCount,
            createdAt: createdAt,
          ),
        ));
}

class $$GoalTemplatesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $GoalTemplatesTable> {
  $$GoalTemplatesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get plannedDuration => $state.composableBuilder(
      column: $state.table.plannedDuration,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get usageCount => $state.composableBuilder(
      column: $state.table.usageCount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$GoalTemplatesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $GoalTemplatesTable> {
  $$GoalTemplatesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get plannedDuration => $state.composableBuilder(
      column: $state.table.plannedDuration,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get usageCount => $state.composableBuilder(
      column: $state.table.usageCount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$AppUsageRecordsTableTableManager get appUsageRecords =>
      $$AppUsageRecordsTableTableManager(_db, _db.appUsageRecords);
  $$UserLabelsTableTableManager get userLabels =>
      $$UserLabelsTableTableManager(_db, _db.userLabels);
  $$RecordLabelMappingsTableTableManager get recordLabelMappings =>
      $$RecordLabelMappingsTableTableManager(_db, _db.recordLabelMappings);
  $$DailyStatsTableTableManager get dailyStats =>
      $$DailyStatsTableTableManager(_db, _db.dailyStats);
  $$PinnedLabelsTableTableManager get pinnedLabels =>
      $$PinnedLabelsTableTableManager(_db, _db.pinnedLabels);
  $$GoalTemplatesTableTableManager get goalTemplates =>
      $$GoalTemplatesTableTableManager(_db, _db.goalTemplates);
}
