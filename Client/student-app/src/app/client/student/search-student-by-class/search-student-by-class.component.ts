import { Component, OnInit } from '@angular/core';
import { MainService } from '../../../shared/services/main.service';
import { CourseListService } from '../course-list/course-list.service';
import { StudentService } from '../student.service';

@Component({
  selector: 'app-search-student-by-class',
  templateUrl: './search-student-by-class.component.html',
  styleUrls: ['./search-student-by-class.component.css']
})
export class SearchStudentByClassComponent implements OnInit {

  page: number = 1;
  createdYears:string[];
  departments:any[];
  studentClasses:any[];
  students:any[];

  constructor(public studentService: StudentService, public mainService:MainService,private courseService: CourseListService)
  {

  }
  ngOnInit(): void {

   this.mainService.getYears().subscribe(years=>{
      this.createdYears=years;
   });

   this.courseService.GetDepartments().subscribe(de=>{
       this.departments=de;
   })

  }

  getClasses(year,departmentId){
      this.studentService.getStudentClasses(year,departmentId).subscribe(res=>{
          this.studentClasses=res;
      });
  }
  getStudent(departmentId,classId){
    this.studentService.getStudentsByClassAndDepartment(departmentId,classId).subscribe(sts=>{
      this.students=sts;
    })
  }
}
