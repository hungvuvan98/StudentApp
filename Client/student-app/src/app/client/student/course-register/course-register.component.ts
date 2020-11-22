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
              private courseService:CourseRegisterService) {}

  ngOnInit(): void {

    this.authService.getUserId().subscribe(res1=>{
      this.studentId=res1
      this.GetLevel()
      this.studentService.GetInfo(this.studentId).subscribe(res2=>{
           this.studentName=res2['name']       
      })
      this.courseService.GetClassNameByStudent(this.studentId).subscribe(res3 => {
          this.className=res3
      })
    })
   
    this.mainService.getNewestSemester().subscribe(res=> {
      this.semester=res
      this.GetRegisteredClass(this.semester,this.studentId)   
    })

  }

  GetLevel(){
    this.studentService.GetLevel().subscribe(res=>{
      this.maxRegister=res
    })
  }

  RegisterClassTemp(classId) {
    if (classId) {
      this.courseService.RegisterClassTemp(classId, this.semester).subscribe(response => {    

        if (this.listRegisteredClass.find(x => x.secId == response.secId) == undefined) {
          this.listRegisteredClass.push(response)
          this.courseService.CheckDuplicateTime(this.listRegisteredClass).subscribe(data => {
            if (data == '1') {    
              this.noticeService.show('info', `Đã thêm lớp ${response.secId} - ${response.title} vào hàng chờ đăng ký`)
            }
            else
            {
              this.listRegisteredClass.pop();
              this.noticeService.show('error',`Bị trùng thời khóa biểu với ${data}`) 
            }    
          })
        }
        else{
            this.noticeService.show('warning',`Lớp ${response.secId} - ${response.title} (${response.courseId}) đã tồn tại`) 
        }       
        this.TotalCredit(this.listRegisteredClass)
      })
    }
    else this.noticeService.show("warning","Nhập mã lớp")
    
  }
  
  TotalCredit(data:any[]){
    this.totalCredit=0
    for (let i = 0; i < data.length; i++) {
      this.totalCredit += data[i].credit
    }
  }
  SendRegister(data){
    this.courseService.SendRegister(data).subscribe(res => {
      
      if (res[0] == -1) this.noticeService.show('warning', 'Tất cả các lớp đã bị xóa')
      else {
          if(res[0]!=0)
            this.noticeService.show('success',`Có ${res[0]} lớp được thêm mới `)
          if(res[1]!=0)
            this.noticeService.show('error',`Có ${res[1]} lớp bị xóa `)
          this.GetRegisteredClass(this.semester,this.studentId);
      }     
    })
  }

  GetRegisteredClass(semester,studentId){
    this.courseService.GetRegisteredClassByStudentId(semester,studentId).subscribe(res=>{
        this.listRegisteredClass=res
        this.TotalCredit(this.listRegisteredClass)
    })
    // this.ngOnInit();
  }

  isAll(){
    this.listRegisteredClass.length=0
   
  }
 listemp: Array<any>
  isCheckedById(data:string){
     for (let index = 0; index < this.listRegisteredClass.length; index++) {
        if(this.listRegisteredClass[index].secId==data)
          this.listRegisteredClass.splice(index,1)             
      }
  }
}
