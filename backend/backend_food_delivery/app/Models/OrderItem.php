<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class OrderItem extends Model
{
    use HasFactory;

    protected $table = "order_items";
    protected $fillable = [
        'order_id',
        'item_id',
        'quantity',
        'price',

    ];

    public function menu()
    {
        return $this->belongsTo(Menu::class, 'item_id', 'item_id'); 
    }

    public function order()
    {
        return $this->belongsTo(Order::class, 'order_id', 'order_id'); 
    }
}
