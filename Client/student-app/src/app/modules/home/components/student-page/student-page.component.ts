import { Component, Input, OnInit } from '@angular/core';
import { StudentInfo } from '../../models/studentinfo';
import { AuthService } from '../../../../common/services/auth/auth.service';
import { StudentService } from '../../services/student.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-student-page',
  templateUrl: './student-page.component.html',
  styleUrls: ['./student-page.component.css'],
})
export class StudentPageComponent implements OnInit {

  studentId:string
  student: StudentInfo
  constructor(private authService: AuthService,
              private studentService: StudentService,
              private route: Router) {     
              }

  ngOnInit(): void {
    if(this.authService.isAuthenticated()==false){
      this.route.navigate(['/login'])
    }
    else{
    this.studentId=this.authService.getStudentId()
    this.GetInfo()
    }
  }
  GetInfo(){
      this.studentService.GetInfo(this.studentId).subscribe(res=>{
          this.student=res
      })
  }

  Logout(){
    this.studentService.Logout()
  }
  show1= true
  show2=true
  drop(data){
    if(data=='1'){
      if(this.show1==false) this.show1=true
      else this.show1=false
    }
    if(data=='2'){
      if(this.show2==false) this.show2=true
      else this.show2=false
    }
    
  }
  
}
