import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { AnnouncementComponent } from './annoucement/announcement.component';
import { ChangePasswordComponent } from './change-password/change-password.component';
import { ClassListComponent } from './class-list/class-list.component';
import { CourseRegisterComponent } from './course-register/course-register.component';
import { HomeComponent } from './home/home.component';
import { StudentClassComponent } from './student-class/student-class.component';
import { UpdateProfileComponent } from './update-profile/update-profile.component';

const routes: Routes = [
  { path: '', component: HomeComponent },
  { path: 'announcement', component: AnnouncementComponent },
  { path: 'class-list', component: ClassListComponent },
  { path: 'course-register', component: CourseRegisterComponent },
  { path: 'update-profile', component: UpdateProfileComponent },
  { path: 'change-password', component: ChangePasswordComponent },
  { path: 'student-class', component: StudentClassComponent },
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class StudentRoutingModule { }
