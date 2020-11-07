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
import { FormsModule } from '@angular/forms';
import { StudentClassComponent } from './student-class/student-class.component';
import { NgxPaginationModule } from 'ngx-pagination';


@NgModule({
  declarations: [CourseRegisterComponent, ChangePasswordComponent, ClassListComponent, HomeComponent, SidebarComponent, AnnouncementComponent, UpdateProfileComponent, StudentClassComponent],
  imports: [
    CommonModule,
    FormsModule,
    StudentRoutingModule,
    NgxPaginationModule
  ]
})
export class StudentModule { }
