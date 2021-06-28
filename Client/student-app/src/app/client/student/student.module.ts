import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';

import { StudentRoutingModule } from './student-routing.module';
import { CourseRegisterComponent } from './course-register/course-register.component';
import { ChangePasswordComponent } from './change-password/change-password.component';
import { ClassListComponent } from './class-list/class-list.component';
import { HomeComponent } from './home/home.component';
import { SidebarComponent } from './sidebar/sidebar.component';
import { AnnouncementComponent } from './annoucement/announcement.component';
import { UpdateProfileComponent } from './update-profile/update-profile.component';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { StudentClassComponent } from './student-class/student-class.component';
import { NgxPaginationModule } from 'ngx-pagination';
import { TableToeicComponent } from './table-toeic/table-toeic.component';
import { TableScoreComponent } from './table-score/table-score.component';
import { StudentFeeComponent } from './student-fee/student-fee.component';
import { TimetableComponent } from './timetable/timetable.component';
import { SearchRegisterClassComponent } from './search-register-class/search-register-class.component';
import { CourseListComponent } from './course-list/course-list.component';
import { SearchStudentByClassComponent } from './search-student-by-class/search-student-by-class.component';


@NgModule({
  declarations: [
    CourseRegisterComponent,
    ChangePasswordComponent,
    ClassListComponent,
    HomeComponent,
    SidebarComponent,
    AnnouncementComponent,
    UpdateProfileComponent,
    StudentClassComponent,
    TableToeicComponent,
    TableScoreComponent,
    StudentFeeComponent,
    TimetableComponent,
    SearchRegisterClassComponent,
    CourseListComponent,
    SearchStudentByClassComponent
  ],
  imports: [
    CommonModule,
    ReactiveFormsModule,
    FormsModule,
    StudentRoutingModule,
    NgxPaginationModule
  ]
})
export class StudentModule { }
