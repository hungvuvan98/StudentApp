import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import {ReactiveFormsModule, FormsModule} from '@angular/forms';
import { HomeRoutingModule } from './home-routing.module';
import { HomeComponent } from './home.component';
import { HeaderComponent } from './components/header/header.component';
import { FooterComponent } from './components/footer/footer.component';
import{AuthComponent} from'./components/auth/auth.component';
import { CourseRegisterComponent } from './components/course-register/course-register.component';
import { StudentPageComponent } from './components/student-page/student-page.component';
import { HomePageComponent } from './components/home-page/home-page.component';
import { StudentService } from './services/student.service';
import { NotificationComponent } from './components/notification/notification.component';
import { ChangePasswordComponent } from './components/change-password/change-password.component';
import { StudentClassInfoComponent } from './components/student-class-info/student-class-info.component';
import { UpdateStudentProfileComponent } from './components/update-student-profile/update-student-profile.component';
import { StudentHomeComponent } from './components/student-home/student-home.component';
import { ListClassComponent } from './components/list-class/list-class.component';
import { NgxPaginationModule } from 'ngx-pagination';
import { DepartmentService } from './services/department.service';
import { StudentClassService } from './services/student-class.service';

@NgModule({
  declarations: [
    HomeComponent,
    HeaderComponent, 
    FooterComponent,
    AuthComponent,
    CourseRegisterComponent,
    StudentPageComponent,
    HomePageComponent,
    NotificationComponent,
    ChangePasswordComponent,
    StudentClassInfoComponent,
    UpdateStudentProfileComponent,
    StudentHomeComponent,
    ListClassComponent,
  ],
  imports: [
    CommonModule,
    HomeRoutingModule,
    FormsModule,
    ReactiveFormsModule,
    NgxPaginationModule
  ],
  providers: [
    StudentService,
    
  ],
})
export class HomeModule { }
