import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { AuthService } from '../../../shared/services/auth/auth.service';
import { MainService } from '../../../shared/services/main.service';
import { NotificationService } from '../../../shared/services/Notification/Notification.service';
import { StudentService } from '../student.service';
import { CourseRegisterService } from './course-register.service';

@Component({
  selector: 'app-course-register',
  templateUrl: './course-register.component.html',
  styleUrls: ['./course-register.component.css'],
  providers:[CourseRegisterService]
})
export class CourseRegisterComponent implements OnInit {

  studentId: string
  className: string
  studentName:any
  maxRegister: number
  listRegisteredClass:any[]
  listtemp:any[]
  totalCredit:number=0
  isAllChecked =false
  semester:string
  constructor(private authService:AuthService, private studentService: StudentService,
              private mainService:MainService, private noticeService: NotificationService,
              private courseService:CourseRegisterService, private route: Router) {}

  ngOnInit(): void {

    this.authService.getUserId().subscribe(res=>{
      this.studentId=res
      this.GetLevel(this.studentId)
      this.studentService.GetInfo(this.studentId).subscribe(res=>{
        this.studentName=res['name']       
      })
    })
   
    this.mainService.getNewestSemester().subscribe(res=> {
      this.semester=res
      this.GetRegisteredClass(this.semester,this.studentId)   
    })

  }

  GetLevel(studentId){
    this.studentService.GetLevel(studentId).subscribe(res=>{
      if(res==0|| res==-1) this.maxRegister=24
      else if(res==1) this.maxRegister=18
      else if(res==2) this.maxRegister=14
      else this.maxRegister=0
    })
  }

  RegisterClassTemp(classId){
    this.courseService.RegisterClassTemp(classId,this.semester).subscribe(res=>{      
        if(this.listRegisteredClass.find(x=>x.secId==res.secId)==undefined){
          this.listRegisteredClass.push(res)
          this.noticeService.show('info',`Đã thêm lớp ${res.secId} - ${res.title} vào hàng chờ đăng ký`)       
        }
        else{
          this.noticeService.show('warning',`Lớp ${res.secId} - ${res.title} (${res.courseId}) đã tồn tại`) 
        }      
        this.TotalCredit(this.listRegisteredClass)
    })
  }
  
  TotalCredit(data:any[]){
    this.totalCredit=0
    for (let i = 0; i < data.length; i++) {
      this.totalCredit += data[i].credit
    }
  }
  SendRegister(data){
    this.courseService.SendRegister(data).subscribe(res=>{
      if(res[0]!=0)
         this.noticeService.show('success',`Có ${res[0]} lớp được thêm mới `)
      if(res[1]!=0)
         this.noticeService.show('error',`Có ${res[1]} lớp bị xóa `)
      this.GetRegisteredClass(this.semester,this.studentId);
    })
  }

  GetRegisteredClass(semester,studentId){
    this.courseService.GetRegisteredClassByStudentId(semester,studentId).subscribe(res=>{
        this.listRegisteredClass=res
        this.TotalCredit(this.listRegisteredClass)
    })
  }

  isAll(){
    this.listRegisteredClass.length=0
    console.log(this.listRegisteredClass)
  }
 listemp: Array<any>
  isCheckedById(data:string){
     for (let index = 0; index < this.listRegisteredClass.length; index++) {
        if(this.listRegisteredClass[index].secId==data)
          this.listRegisteredClass.splice(index,1)             
      }
  }
}
