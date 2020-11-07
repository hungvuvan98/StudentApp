import { Component, OnInit } from '@angular/core';
import { AuthService } from '../../../shared/services/auth/auth.service';
import { StudentService } from '../student.service';

@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.css']
})
export class HomeComponent implements OnInit {

  studentId:string
  departmentName:string
  studentClassName:string
  student: any
  resultLeaning:any
  constructor(private authService : AuthService, private studentService : StudentService){}

  ngOnInit(): void {
    this.authService.getUserId().subscribe( res=>{
      this.studentId=res
      this.GetInfo(this.studentId)
       //this.GetStudentClass(this.studentId)
      this.GetResultLearning(this.studentId)
    })  
  }
  
  GetInfo(id){
    this.studentService.GetInfo(id).subscribe(res=>{
        this.student=res
        this.GetDepartment(this.student.departmentId)
    })
  }
  GetDepartment(id){
    this.studentService.GetDepartment(id).subscribe(res=>{
      this.departmentName=res
    })
  }
  GetStudentClass(id){
    this.studentService.GetStudentClass(id).subscribe(res=>{
      this.studentClassName=res
    })
  }
  GetResultLearning(id){
    this.studentService.GetResultLearning(id).subscribe(res=>{
        this.resultLeaning=res[res.length-1]
    })
  }

}
