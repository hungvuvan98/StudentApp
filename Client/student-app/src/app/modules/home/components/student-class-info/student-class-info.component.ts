import { Component, OnInit } from '@angular/core';
import { AuthService } from '../../../../common/services/auth/auth.service';
import { StudentInfo } from '../../models/studentinfo';
import { StudentClassService } from '../../services/student-class.service';

@Component({
  selector: 'app-student-class-info',
  templateUrl: './student-class-info.component.html',
  styleUrls: ['./student-class-info.component.css'],
  providers:[StudentClassService]
})
export class StudentClassInfoComponent implements OnInit {

  studentId:string
  students:StudentInfo[]
  constructor(private studentClassService :StudentClassService,
              private authService:AuthService) { }

  ngOnInit(): void {
    
    this.studentId=this.authService.getStudentId()
    this.getListStudent()
  }
  getListStudent(){
    this.studentClassService.GetListStudent(this.studentId).subscribe(res=>{      
        this.students=res
    })
  }
}
