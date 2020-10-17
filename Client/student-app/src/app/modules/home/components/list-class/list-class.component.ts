import { Component, OnInit } from '@angular/core';
import { ListClassService } from '../../services/list-class.service';
import { ListClass } from '../../models/list-class';
import { NgbModal } from '@ng-bootstrap/ng-bootstrap';
import { NotificationService } from '../../../../common/notification.service';
import { MainService } from '../../../../common/services/main.service';

@Component({
  selector: 'app-list-class',
  templateUrl: './list-class.component.html',
  styleUrls: ['./list-class.component.css'],
  providers:[ListClassService]
})
export class ListClassComponent implements OnInit {

  listClass: ListClass[]
  detailClass:ListClass
  config: any
  message:string
  semester:string
  constructor(private classService:ListClassService,
              private mainService:MainService,
              private modalService: NgbModal,
              private notiService:NotificationService) {
    this.PageAction(event)
   }

  ngOnInit(): void {
    this.message=undefined
    this.mainService.getNewestSemester().subscribe(res=>{
      this.semester=res
      this.GetAll(this.semester)
      
    })  
  }
  GetAll(semester){
    this.classService.GetAll(semester).subscribe(res=>{
      this.listClass=res
      console.log(res)
    })
  }

  Detail(secId){
    this.detailClass=this.listClass.find(x=>x.secId==secId)
  }

  SearchBySecId(secId: string){
    if(secId!=''){      
        var st : ListClass[]
        st = this.listClass.filter(x=>x.secId==secId)                             
        if(st.length!=0){
          this.listClass.length = 0
          this.listClass=st
          this.message=` Có ${st.length} bản ghi được tìm thấy`         
        }     
    }
    else{
        this.ngOnInit()
    }
  }
  SearchByCourseId(courseId: string){
    if(courseId!=''){      
        var st : ListClass[]
        st = this.listClass.filter(x=>x.courseId==courseId)                             
        if(st.length!=0){
          this.listClass.length = 0
          this.listClass=st
          this.message=` Có ${st.length} bản ghi được tìm thấy`    
        }     
    }
    else{
        this.ngOnInit()
    }
  }
  SearchByCredit(credit){
    if(credit!=''){      
        var st : ListClass[]
        st = this.listClass.filter(x=>x.credit==parseInt(credit))                             
        if(st.length!=0){
          this.listClass.length = 0
          this.listClass=st
          this.message=` Có ${st.length} bản ghi được tìm thấy`    
        }     
    }
    else{
        this.ngOnInit()
    }
  }
  SearchByDepartment(dept){
    if(dept!=''){      
        var st : ListClass[]
        st = this.listClass.filter(x=>x.name.toLowerCase().includes(dept.toLowerCase()))                             
        if(st.length!=0){
          this.listClass.length = 0
          this.listClass=st
          this.message=` Có ${st.length} bản ghi được tìm thấy`    
        }     
    }
    else{
        this.ngOnInit()
    }
  }
  SearchByTitle(title){
    if(title!=''){      
        var st : ListClass[]
        st = this.listClass.filter(x=>x.title.toLowerCase().includes(title.toLowerCase()))                             
        if(st.length!=0){
          this.listClass.length = 0
          this.listClass=st
          this.message=` Có ${st.length} bản ghi được tìm thấy`    
        }     
    }
    else{
        this.ngOnInit()
    }
  }
  

  PageAction(event){
    this.config = {
      itemsPerPage: 20,
      currentPage: 1,
      totalItems: this.listClass?.length
    }
    // call if page changed
    this.config.currentPage = event
  }

  ShowDetailClass(detail){
    this.modalService.open(detail, { scrollable: true,size: 'xl' })
  }
}
