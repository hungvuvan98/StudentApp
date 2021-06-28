import { Component, OnInit } from '@angular/core';
import { AuthService } from '../../../shared/services/auth/auth.service';
import { MainService } from '../../../shared/services/main.service';
import { CourseRegisterService } from '../course-register/course-register.service';
import { StudentService } from '../student.service';

@Component({
  selector: 'app-search-register-class',
  templateUrl: './search-register-class.component.html',
  styleUrls: ['./search-register-class.component.css'],
  providers:[CourseRegisterService,StudentService]
})
export class SearchRegisterClassComponent implements OnInit {

  semesters:any[];
  studentId:string; // current Student is logging in system.
  registeredClass:any[];
  Student:any; // find student in system
  constructor(private mainService:MainService,private authService:AuthService,
      private courseService:CourseRegisterService,private studentService:StudentService)
   {

   }

  ngOnInit(): void {
    this.authService.getUserId().subscribe(user=>{
      this.studentId=user;
      this.studentService.GetInfo(user).subscribe(student=>{
        this.Student=student;
      })
      this.getSemester(user);
    });
  }

  getSemester(studentId):void{
      this.mainService.getSemesters(studentId).subscribe(res=>{
        this.semesters=res;
        this.courseService.GetRegisteredClassByStudentId(res[0],studentId).subscribe(res=>{
          this.registeredClass=res;
      })
      });
  }

  onSelectChange(semester:string,studentIdClient:string):void{
    this.Student=null;
    this.registeredClass=null;
    this.studentService.GetInfo(studentIdClient).subscribe(user=>{
      this.Student=user;
      this.courseService.GetRegisteredClassByStudentId(semester,studentIdClient).subscribe(res=>{
        this.registeredClass=res;
      });
    });
  }

}
