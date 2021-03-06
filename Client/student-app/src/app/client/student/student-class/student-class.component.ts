import { Component, OnInit } from '@angular/core';
import { AuthService } from '../../../shared/services/auth/auth.service';
import { StudentService } from '../student.service';

@Component({
  selector: 'app-student-class',
  templateUrl: './student-class.component.html',
  styleUrls: ['./student-class.component.css']
})
export class StudentClassComponent implements OnInit {

  studentId:string;
  students:any[];
  studentClass: string
  constructor(private studentService :StudentService, private authService:AuthService) { }

  ngOnInit(): void {

    this.authService.getUserId().subscribe(res=>{
      this.studentId=res
      this.studentService.GetListStudent(this.studentId).subscribe(stu=>{
        this.students=stu
    });
      this.studentService.GetStudentClass(res).subscribe(cla=>{
          this.studentClass=cla;
      })
    });
  }

}
