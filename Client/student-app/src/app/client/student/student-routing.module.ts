import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { AnnouncementComponent } from './annoucement/announcement.component';
import { ChangePasswordComponent } from './change-password/change-password.component';
import { ClassListComponent } from './class-list/class-list.component';
import { CourseListComponent } from './course-list/course-list.component';
import { CourseRegisterComponent } from './course-register/course-register.component';
import { HomeComponent } from './home/home.component';
import { SearchRegisterClassComponent } from './search-register-class/search-register-class.component';
import { SearchStudentByClassComponent } from './search-student-by-class/search-student-by-class.component';
import { StudentClassComponent } from './student-class/student-class.component';
import { StudentFeeComponent } from './student-fee/student-fee.component';
import { TableScoreComponent } from './table-score/table-score.component';
import { TableToeicComponent } from './table-toeic/table-toeic.component';
import { TimetableComponent } from './timetable/timetable.component';
import { UpdateProfileComponent } from './update-profile/update-profile.component';

const routes: Routes = [
  { path: '', component: HomeComponent },
  { path: 'announcement', component: AnnouncementComponent },
  { path: 'class-list', component: ClassListComponent },
  { path: 'course-register', component: CourseRegisterComponent },
  { path: 'update-profile', component: UpdateProfileComponent },
  { path: 'change-password', component: ChangePasswordComponent },
  { path: 'student-class', component: StudentClassComponent },
  { path: 'table-toeic', component: TableToeicComponent },
  { path: 'table-score', component: TableScoreComponent },
  { path: 'tuition-fee', component: StudentFeeComponent },
  { path: 'timetable', component: TimetableComponent },
  { path: 'search-register', component: SearchRegisterClassComponent },
  { path: 'course-list', component: CourseListComponent },
  { path: 'search-student-by-class', component: SearchStudentByClassComponent },

];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class StudentRoutingModule { }
