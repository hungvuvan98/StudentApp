﻿// <auto-generated />
using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using StudentAppServer.Data;

namespace StudentAppServer.Data.Migrations
{
    [DbContext(typeof(AppDbContext))]
    [Migration("20200908081826_addsemester")]
    partial class addsemester
    {
        protected override void BuildTargetModel(ModelBuilder modelBuilder)
        {
#pragma warning disable 612, 618
            modelBuilder
                .HasAnnotation("ProductVersion", "3.1.7")
                .HasAnnotation("Relational:MaxIdentifierLength", 128)
                .HasAnnotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn);

            modelBuilder.Entity("StudentAppServer.Data.Entities.AppGroup", b =>
                {
                    b.Property<string>("Id")
                        .HasColumnName("Id")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<string>("Name")
                        .HasColumnName("Name")
                        .HasColumnType("nvarchar(100)")
                        .HasMaxLength(100);

                    b.Property<string>("Role")
                        .HasColumnName("Role")
                        .HasColumnType("nvarchar(50)")
                        .HasMaxLength(50);

                    b.Property<int>("Status")
                        .HasColumnType("int");

                    b.HasKey("Id")
                        .HasName("PK__Appgroup");

                    b.ToTable("AppGroups");
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.Classroom", b =>
                {
                    b.Property<string>("Building")
                        .HasColumnName("Building")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<string>("RoomNumber")
                        .HasColumnName("RoomNumber")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<int>("Capacity")
                        .HasColumnType("int");

                    b.Property<int>("Status")
                        .HasColumnType("int");

                    b.HasKey("Building", "RoomNumber")
                        .HasName("PK__classroom");

                    b.ToTable("Classrooms");
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.Course", b =>
                {
                    b.Property<string>("CourseId")
                        .HasColumnName("CourseId")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<int>("Credits")
                        .HasColumnType("int");

                    b.Property<string>("DepartmentId")
                        .HasColumnName("DepartmentId")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<string>("Title")
                        .HasColumnName("Title")
                        .HasColumnType("nvarchar(200)")
                        .HasMaxLength(200);

                    b.HasKey("CourseId");

                    b.HasIndex("DepartmentId");

                    b.ToTable("Courses");
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.Department", b =>
                {
                    b.Property<string>("DepartmentId")
                        .HasColumnName("DepartmentId")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<string>("Building")
                        .HasColumnName("Building")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<string>("Name")
                        .HasColumnName("Name")
                        .HasColumnType("nvarchar(200)")
                        .HasMaxLength(200);

                    b.Property<int>("Status")
                        .HasColumnType("int");

                    b.HasKey("DepartmentId")
                        .HasName("PK__department");

                    b.ToTable("Departments");
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.Feedback", b =>
                {
                    b.Property<string>("Id")
                        .HasColumnName("ID")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<DateTime?>("DateCreated")
                        .HasColumnType("datetime2");

                    b.Property<string>("Email")
                        .HasColumnName("Email")
                        .HasColumnType("nvarchar(200)")
                        .HasMaxLength(200);

                    b.Property<string>("Message")
                        .HasColumnType("nvarchar(max)");

                    b.Property<string>("Name")
                        .HasColumnName("Name")
                        .HasColumnType("nvarchar(200)")
                        .HasMaxLength(200);

                    b.Property<int>("Status")
                        .HasColumnType("int");

                    b.HasKey("Id")
                        .HasName("PK__feedback");

                    b.ToTable("Feedbacks");
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.Instructor", b =>
                {
                    b.Property<string>("Id")
                        .HasColumnName("ID")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<string>("Address")
                        .HasColumnType("nvarchar(max)");

                    b.Property<string>("Avatar")
                        .HasColumnType("nvarchar(max)");

                    b.Property<string>("Birthplace")
                        .HasColumnType("nvarchar(max)");

                    b.Property<DateTime?>("BitrhDay")
                        .HasColumnType("datetime2");

                    b.Property<int?>("CardId")
                        .HasColumnType("int");

                    b.Property<string>("CreatedYear")
                        .HasColumnType("nvarchar(max)");

                    b.Property<string>("DepartmentId")
                        .HasColumnName("DepartmentId")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<string>("Email")
                        .HasColumnType("nvarchar(max)");

                    b.Property<int>("Gender")
                        .HasColumnType("int");

                    b.Property<string>("GroupId")
                        .HasColumnType("nvarchar(20)");

                    b.Property<string>("InstructorDepartmentId")
                        .HasColumnName("InstructorDepartmentId")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<string>("Name")
                        .IsRequired()
                        .HasColumnName("Name")
                        .HasColumnType("nvarchar(200)")
                        .HasMaxLength(200);

                    b.Property<string>("Password")
                        .HasColumnType("nvarchar(max)");

                    b.Property<decimal?>("Salary")
                        .HasColumnName("Salary")
                        .HasColumnType("numeric(8, 2)");

                    b.Property<int>("Status")
                        .HasColumnType("int");

                    b.HasKey("Id");

                    b.HasIndex("GroupId");

                    b.HasIndex("InstructorDepartmentId", "DepartmentId");

                    b.ToTable("Instructors");
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.InstructorDepartment", b =>
                {
                    b.Property<string>("Id")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<string>("DepartmentId")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<string>("Description")
                        .HasColumnType("nvarchar(max)");

                    b.Property<string>("Name")
                        .HasColumnType("nvarchar(max)");

                    b.Property<int>("Status")
                        .HasColumnType("int");

                    b.HasKey("Id", "DepartmentId")
                        .HasName("PK_InstructorDepartment");

                    b.HasIndex("DepartmentId");

                    b.ToTable("InstructorDepartments");
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.InstructorNotification", b =>
                {
                    b.Property<string>("InstructorId")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<string>("NotificationId")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.HasKey("InstructorId", "NotificationId")
                        .HasName("PK_InstructorNotice");

                    b.HasIndex("NotificationId");

                    b.ToTable("InstructorNotification");
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.Language", b =>
                {
                    b.Property<string>("Id")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<bool>("IsDefault")
                        .HasColumnType("bit");

                    b.Property<string>("Name")
                        .HasColumnType("nvarchar(max)");

                    b.Property<string>("Resources")
                        .HasColumnType("nvarchar(max)");

                    b.Property<int>("Status")
                        .HasColumnType("int");

                    b.HasKey("Id")
                        .HasName("PK_language");

                    b.ToTable("Languages");
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.Notification", b =>
                {
                    b.Property<string>("Id")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<DateTime?>("CreatedDate")
                        .HasColumnType("datetime2");

                    b.Property<string>("Message")
                        .HasColumnType("nvarchar(max)");

                    b.Property<DateTime?>("ModifiedDate")
                        .HasColumnType("datetime2");

                    b.Property<int>("Status")
                        .HasColumnType("int");

                    b.Property<string>("Title")
                        .HasColumnType("nvarchar(200)")
                        .HasMaxLength(200);

                    b.HasKey("Id")
                        .HasName("PK_Notification");

                    b.ToTable("Notifications");
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.Post", b =>
                {
                    b.Property<string>("Id")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<string>("Content")
                        .HasColumnType("nvarchar(max)");

                    b.Property<string>("CreatedBy")
                        .HasColumnType("nvarchar(max)");

                    b.Property<DateTime?>("CreatedOn")
                        .HasColumnType("datetime2");

                    b.Property<string>("ModifiedBy")
                        .HasColumnType("nvarchar(max)");

                    b.Property<DateTime?>("ModifiedOn")
                        .HasColumnType("datetime2");

                    b.Property<string>("PostCategoryId")
                        .HasColumnType("nvarchar(20)");

                    b.Property<int>("Status")
                        .HasColumnType("int");

                    b.HasKey("Id")
                        .HasName("PK_Post");

                    b.HasIndex("PostCategoryId");

                    b.ToTable("Posts");
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.PostCategory", b =>
                {
                    b.Property<string>("Id")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<string>("Name")
                        .HasColumnType("nvarchar(max)");

                    b.Property<int>("Status")
                        .HasColumnType("int");

                    b.HasKey("Id")
                        .HasName("PK_Postcategory");

                    b.ToTable("PostCategories");
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.Prereq", b =>
                {
                    b.Property<string>("CourseId")
                        .HasColumnName("CourseId")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<string>("PrereqId")
                        .HasColumnName("PrereqId")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<int>("Status")
                        .HasColumnType("int");

                    b.HasKey("CourseId", "PrereqId")
                        .HasName("PK__prereq");

                    b.ToTable("Prereqs");
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.Section", b =>
                {
                    b.Property<string>("SecId")
                        .HasColumnName("SecId")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<string>("Building")
                        .HasColumnName("Building")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<string>("CourseId")
                        .HasColumnName("CourseId")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<string>("Day")
                        .HasColumnName("Day")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<string>("RoomNumber")
                        .HasColumnName("RoomNumber")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<string>("Semester")
                        .HasColumnName("Semester")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<int>("Status")
                        .HasColumnType("int");

                    b.Property<string>("TimeSlotId")
                        .HasColumnName("TimeSlotId")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<string>("Year")
                        .HasColumnName("Year")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.HasKey("SecId")
                        .HasName("PK__section");

                    b.HasIndex("CourseId");

                    b.HasIndex("Building", "RoomNumber");

                    b.HasIndex("TimeSlotId", "Day");

                    b.ToTable("Sections");
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.Semester", b =>
                {
                    b.Property<string>("Id")
                        .HasColumnName("Id")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.HasKey("Id")
                        .HasName("PK__semester");

                    b.ToTable("Semesters");
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.Student", b =>
                {
                    b.Property<string>("Id")
                        .HasColumnName("Id")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<string>("Address")
                        .HasColumnType("nvarchar(max)");

                    b.Property<string>("Avatar")
                        .HasColumnType("nvarchar(max)");

                    b.Property<DateTime?>("BirthDay")
                        .HasColumnType("datetime2");

                    b.Property<string>("Birthplace")
                        .HasColumnType("nvarchar(max)");

                    b.Property<int?>("CardId")
                        .HasColumnType("int");

                    b.Property<string>("CreatedYear")
                        .HasColumnName("CreatedYear")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<string>("DepartmentId")
                        .HasColumnName("DepartmentId")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<string>("Email")
                        .HasColumnType("nvarchar(max)");

                    b.Property<string>("GroupId")
                        .HasColumnType("nvarchar(20)");

                    b.Property<string>("Name")
                        .IsRequired()
                        .HasColumnName("Name")
                        .HasColumnType("nvarchar(200)")
                        .HasMaxLength(200);

                    b.Property<string>("Password")
                        .HasColumnName("Password")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<int>("Status")
                        .HasColumnType("int");

                    b.Property<string>("StudentClassId")
                        .HasColumnName("StudentClassId")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.HasKey("Id")
                        .HasName("PK__Student");

                    b.HasIndex("GroupId");

                    b.HasIndex("StudentClassId", "DepartmentId");

                    b.ToTable("Students");
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.StudentClass", b =>
                {
                    b.Property<string>("Id")
                        .HasColumnName("Id")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<string>("DepartmentId")
                        .HasColumnName("DepartmentId")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<string>("Name")
                        .IsRequired()
                        .HasColumnName("Name")
                        .HasColumnType("nvarchar(200)")
                        .HasMaxLength(200);

                    b.Property<int?>("Status")
                        .HasColumnType("int");

                    b.Property<string>("Year")
                        .IsRequired()
                        .HasColumnName("Year")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.HasKey("Id", "DepartmentId")
                        .HasName("PK__StudentClass");

                    b.HasIndex("DepartmentId");

                    b.ToTable("StudentClasses");
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.StudentNotification", b =>
                {
                    b.Property<string>("StudentId")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<string>("NotificationId")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.HasKey("StudentId", "NotificationId")
                        .HasName("PK_StudentNotice");

                    b.HasIndex("NotificationId");

                    b.ToTable("StudentNotification");
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.Take", b =>
                {
                    b.Property<string>("Id")
                        .HasColumnName("ID")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<string>("SecId")
                        .HasColumnName("SecId")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<float?>("Endterm")
                        .HasColumnType("real");

                    b.Property<float?>("Midterm")
                        .HasColumnType("real");

                    b.Property<string>("WordScore")
                        .HasColumnName("WordScore")
                        .HasColumnType("nvarchar(2)")
                        .HasMaxLength(2);

                    b.HasKey("Id", "SecId")
                        .HasName("PK__takes__A0A7458A976F2631");

                    b.HasIndex("SecId");

                    b.ToTable("Takes");
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.Teach", b =>
                {
                    b.Property<string>("Id")
                        .HasColumnName("ID")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<string>("SecId")
                        .HasColumnName("SecId")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.HasKey("Id", "SecId")
                        .HasName("PK__teaches__A0A7458ABC151A07");

                    b.HasIndex("SecId");

                    b.ToTable("Teaches");
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.TimeSlot", b =>
                {
                    b.Property<string>("TimeSlotId")
                        .HasColumnName("TimeSlotId")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<string>("Day")
                        .HasColumnName("Day")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<int?>("EndHr")
                        .HasColumnType("int");

                    b.Property<int?>("EndMin")
                        .HasColumnType("int");

                    b.Property<int?>("StartHr")
                        .HasColumnType("int");

                    b.Property<int?>("StartMin")
                        .HasColumnType("int");

                    b.HasKey("TimeSlotId", "Day")
                        .HasName("PK__timeslot");

                    b.ToTable("TimeSlots");
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.ToeicPoint", b =>
                {
                    b.Property<string>("Id")
                        .HasColumnName("ID")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<string>("StudentId")
                        .HasColumnName("StudentId")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<DateTime?>("CreatedDate")
                        .HasColumnType("datetime2");

                    b.Property<string>("Description")
                        .HasColumnType("nvarchar(max)");

                    b.Property<int>("HearPoint")
                        .HasColumnType("int");

                    b.Property<int>("ReadPoint")
                        .HasColumnType("int");

                    b.Property<string>("Semester")
                        .HasColumnType("nvarchar(max)");

                    b.Property<int>("TotalPoint")
                        .HasColumnType("int");

                    b.Property<string>("year")
                        .HasColumnType("nvarchar(max)");

                    b.HasKey("Id", "StudentId")
                        .HasName("PK__toeicpoint");

                    b.HasIndex("StudentId");

                    b.ToTable("ToeicPoints");
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.Warn", b =>
                {
                    b.Property<string>("StudentId")
                        .HasColumnName("StudentId")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<string>("Semester")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<int>("Level")
                        .HasColumnType("int");

                    b.HasKey("StudentId", "Semester")
                        .HasName("PK_warn");

                    b.ToTable("Warns");
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.Course", b =>
                {
                    b.HasOne("StudentAppServer.Data.Entities.Department", "Department")
                        .WithMany("Courses")
                        .HasForeignKey("DepartmentId")
                        .HasConstraintName("FK__course__dept_nam__164452B1")
                        .OnDelete(DeleteBehavior.SetNull);
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.Instructor", b =>
                {
                    b.HasOne("StudentAppServer.Data.Entities.AppGroup", "AppGroup")
                        .WithMany("Instructors")
                        .HasForeignKey("GroupId")
                        .HasConstraintName("FK__instructor_Appgroup")
                        .OnDelete(DeleteBehavior.SetNull);

                    b.HasOne("StudentAppServer.Data.Entities.InstructorDepartment", "InstructorDepartment")
                        .WithMany("Instructors")
                        .HasForeignKey("InstructorDepartmentId", "DepartmentId")
                        .HasConstraintName("FK__instructor_instructordepartment")
                        .OnDelete(DeleteBehavior.SetNull);
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.InstructorDepartment", b =>
                {
                    b.HasOne("StudentAppServer.Data.Entities.Department", "Department")
                        .WithMany("InstructorDepartments")
                        .HasForeignKey("DepartmentId")
                        .HasConstraintName("FK__instructordept_dept")
                        .OnDelete(DeleteBehavior.Cascade)
                        .IsRequired();
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.InstructorNotification", b =>
                {
                    b.HasOne("StudentAppServer.Data.Entities.Instructor", "Instructor")
                        .WithMany("InstructorNotifications")
                        .HasForeignKey("InstructorId")
                        .HasConstraintName("FK__instructorNotification12")
                        .OnDelete(DeleteBehavior.Cascade)
                        .IsRequired();

                    b.HasOne("StudentAppServer.Data.Entities.Notification", "Notification")
                        .WithMany("InstructorNotifications")
                        .HasForeignKey("NotificationId")
                        .HasConstraintName("FK__NoticeInstrucNotification")
                        .OnDelete(DeleteBehavior.Cascade)
                        .IsRequired();
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.Post", b =>
                {
                    b.HasOne("StudentAppServer.Data.Entities.PostCategory", "PostCategory")
                        .WithMany("Posts")
                        .HasForeignKey("PostCategoryId")
                        .HasConstraintName("FK__Post_PostCategory")
                        .OnDelete(DeleteBehavior.SetNull);
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.Prereq", b =>
                {
                    b.HasOne("StudentAppServer.Data.Entities.Course", "Course")
                        .WithMany("Prereqs")
                        .HasForeignKey("CourseId")
                        .HasConstraintName("FK__prereq__course")
                        .IsRequired();
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.Section", b =>
                {
                    b.HasOne("StudentAppServer.Data.Entities.Course", "Course")
                        .WithMany("Sections")
                        .HasForeignKey("CourseId")
                        .HasConstraintName("FK__section__course___1ED998B2")
                        .OnDelete(DeleteBehavior.Cascade);

                    b.HasOne("StudentAppServer.Data.Entities.Classroom", "Classroom")
                        .WithMany("Sections")
                        .HasForeignKey("Building", "RoomNumber")
                        .HasConstraintName("FK__section__1FCDBCEB")
                        .OnDelete(DeleteBehavior.SetNull);

                    b.HasOne("StudentAppServer.Data.Entities.TimeSlot", "TimeSlot")
                        .WithMany("Sections")
                        .HasForeignKey("TimeSlotId", "Day")
                        .HasConstraintName("FK__section__timeslot")
                        .OnDelete(DeleteBehavior.SetNull);
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.Student", b =>
                {
                    b.HasOne("StudentAppServer.Data.Entities.AppGroup", "AppGroup")
                        .WithMany("Students")
                        .HasForeignKey("GroupId")
                        .HasConstraintName("FK__student__appgroup")
                        .OnDelete(DeleteBehavior.SetNull);

                    b.HasOne("StudentAppServer.Data.Entities.StudentClass", "StudentClass")
                        .WithMany("Students")
                        .HasForeignKey("StudentClassId", "DepartmentId")
                        .HasConstraintName("FK__student__dept_na__276EDEB3")
                        .OnDelete(DeleteBehavior.SetNull);
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.StudentClass", b =>
                {
                    b.HasOne("StudentAppServer.Data.Entities.Department", "Department")
                        .WithMany("StudentClasses")
                        .HasForeignKey("DepartmentId")
                        .HasConstraintName("FK__studentclass__dept")
                        .OnDelete(DeleteBehavior.Cascade)
                        .IsRequired();
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.StudentNotification", b =>
                {
                    b.HasOne("StudentAppServer.Data.Entities.Notification", "Notification")
                        .WithMany("StudentNotifications")
                        .HasForeignKey("NotificationId")
                        .HasConstraintName("FK__NoticeStudentNotification")
                        .OnDelete(DeleteBehavior.Cascade)
                        .IsRequired();

                    b.HasOne("StudentAppServer.Data.Entities.Student", "Student")
                        .WithMany("StudentNotifications")
                        .HasForeignKey("StudentId")
                        .HasConstraintName("FK__StudentNotification12")
                        .OnDelete(DeleteBehavior.Cascade)
                        .IsRequired();
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.Take", b =>
                {
                    b.HasOne("StudentAppServer.Data.Entities.Student", "Student")
                        .WithMany("Takes")
                        .HasForeignKey("Id")
                        .HasConstraintName("FK__takes__ID__2B3F6F97")
                        .OnDelete(DeleteBehavior.Cascade)
                        .IsRequired();

                    b.HasOne("StudentAppServer.Data.Entities.Section", "Section")
                        .WithMany("Takes")
                        .HasForeignKey("SecId")
                        .HasConstraintName("FK__takes__2A4B4B5E")
                        .OnDelete(DeleteBehavior.Cascade)
                        .IsRequired();
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.Teach", b =>
                {
                    b.HasOne("StudentAppServer.Data.Entities.Instructor", "Instructor")
                        .WithMany("Teaches")
                        .HasForeignKey("Id")
                        .HasConstraintName("FK__teaches_instructor")
                        .OnDelete(DeleteBehavior.Cascade)
                        .IsRequired();

                    b.HasOne("StudentAppServer.Data.Entities.Section", "Section")
                        .WithMany("Teaches")
                        .HasForeignKey("SecId")
                        .HasConstraintName("FK__teaches_section")
                        .OnDelete(DeleteBehavior.Cascade)
                        .IsRequired();
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.ToeicPoint", b =>
                {
                    b.HasOne("StudentAppServer.Data.Entities.Student", "Student")
                        .WithMany("ToeicPoints")
                        .HasForeignKey("StudentId")
                        .HasConstraintName("FK__toeic_student")
                        .OnDelete(DeleteBehavior.Cascade)
                        .IsRequired();
                });

            modelBuilder.Entity("StudentAppServer.Data.Entities.Warn", b =>
                {
                    b.HasOne("StudentAppServer.Data.Entities.Student", "Student")
                        .WithMany("Warns")
                        .HasForeignKey("StudentId")
                        .HasConstraintName("FK__warnc_student")
                        .OnDelete(DeleteBehavior.Cascade)
                        .IsRequired();
                });
#pragma warning restore 612, 618
        }
    }
}
