import { Component, OnInit } from '@angular/core';
import { AuthService } from '../../../../common/services/auth/auth.service';
import { StudentService } from '../../services/student.service';
import { StudentInfo } from '../../models/studentinfo';
import { ResultLearning } from '../../../admin/models/student/resultlearning';
import { DepartmentService } from '../../services/department.service';
import { StudentClassService } from '../../services/student-class.service';

@Component({
  selector: 'app-student-home',
  templateUrl: './student-home.component.html',
  styleUrls: ['./student-home.component.css'],
  providers:[DepartmentService,
            StudentClassService,]
})
export class StudentHomeComponent implements OnInit {

  studentId:string
  departmentName:string
  studentClassName:string
  student: StudentInfo
  resultLeaning:ResultLearning
  constructor(private authService : AuthService,
              private studentService : StudentService ,
              private departmentService:DepartmentService,
              private stclassService:StudentClassService) { }

  ngOnInit(): void {
    this.studentId=this.authService.getStudentId()
    this.GetInfo();
    this.GetStudentClass(this.studentId)
    this.GetResultLearning(this.studentId)
  }
  
  GetInfo(){
    this.studentService.GetInfo(this.studentId).subscribe(res=>{
        this.student=res
        console.log(this.student.departmentId)
        this.GetDepartment(this.student.departmentId)
    })
  }
  GetDepartment(id){
    this.departmentService.GetById(id).subscribe(res=>{
      console.log(id)
      this.departmentName=res
      console.log(res)
    })
  }
  GetStudentClass(id){
    this.stclassService.GetById(id).subscribe(res=>{
      console.log(id)
      this.studentClassName=res
    })
  }
  GetResultLearning(id){
    this.studentService.GetResultLearning(id).subscribe(res=>{
        this.resultLeaning=res[res.length-1]
    })
  }
}
