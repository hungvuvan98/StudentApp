import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { HomeComponent } from './home.component';
import { CourseRegisterComponent } from './components/course-register/course-register.component';
import { HomePageComponent } from './components/home-page/home-page.component';
import { AuthComponent } from './components/auth/auth.component';
import { StudentPageComponent } from './components/student-page/student-page.component';
import { AuthGuardService } from '../../common/services/auth/auth-guard.service';
import { NotificationComponent } from './components/notification/notification.component';
import { StudentHomeComponent } from './components/student-home/student-home.component';
import { UpdateStudentProfileComponent } from './components/update-student-profile/update-student-profile.component';
import { ListClassComponent } from './components/list-class/list-class.component';
import { StudentClassInfoComponent } from './components/student-class-info/student-class-info.component';

const homeRoutes: Routes = [
  {
    path: '',
    component: HomeComponent,
    children: [
      {
        path: '',
        // canActivateChild: [AuthGuard],
        children: [
          { path: '', component: HomePageComponent },
          { path: 'login', component: AuthComponent },
          { path: 'student', component: StudentPageComponent ,          
            children:[
              {  path: '', component: StudentHomeComponent},
              {  path: 'notification', component: NotificationComponent },
              {  path: 'student-class', component: StudentClassInfoComponent },
              {  path: 'updateStudentProfile', component: UpdateStudentProfileComponent },
             ]
           },     
          { path: 'student/course-register', component: CourseRegisterComponent},
          { path: 'student/class-list', component: ListClassComponent,canActivateChild:[AuthGuardService] },
        ]
      }
    ]
  }
];

@NgModule({
  imports: [RouterModule.forChild(homeRoutes)],
  exports: [RouterModule]
})
export class HomeRoutingModule { }
