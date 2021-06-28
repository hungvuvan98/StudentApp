import { Component, OnInit } from '@angular/core';
import { CourseListService } from './course-list.service';

@Component({
  selector: 'app-course-list',
  templateUrl: './course-list.component.html',
  styleUrls: ['./course-list.component.css'],
  providers:[CourseListService]
})
export class CourseListComponent implements OnInit {

  courses:any[];
  departments:any[];
  constructor(private courseService:CourseListService) { }

  ngOnInit(): void {
    this.courses=null;
    this.courseService.GetDepartments().subscribe(departs=>{
      this.departments=departs;
    });
  }

  GetCourseByDepartment(departmentId:string):void{
    this.courseService.GetCourse(departmentId).subscribe(res=>{
        this.courses=res;
    });
  }

  onSelectChange(departmentId:string){
    console.log(departmentId);

    this.courseService.GetCourse(departmentId).subscribe(res=>{
        this.courses=res;
        console.log(res);

    });
  }
}
